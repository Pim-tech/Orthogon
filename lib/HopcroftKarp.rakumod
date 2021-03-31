
class HopcroftKarp is export {

    has %!matching{Any};
    has @!dfs_paths;
    has %!dfs_parent{Any};
    has %.graph{Any};
    has %!graph_origin{Any};
    has Set $.left; 
    has Set $.right;
    has SetHash $.alternated_paths;
    has Set $.vertices;

    
    #`[
        param graph: an unweighted bipartite graph represented as a dictionary.
        Vertices in the left and right vertex set must have different labelling
        return: a maximum matching of the given graph represented as a dictionary.
     ] 
        multi method new(:%graph ) {
            self.bless(:%graph);
        }
        multi method new(%graph ){
            self.bless(graph => %graph);
        }
        submethod BUILD( :%graph) {
            %!graph = %graph;
            %!graph_origin = %graph;
            $!left = Set.new(%!graph.keys); 
            my @vls;
            for %!graph.values -> @l {
                for @l {
                    push @vls, $_;
                 }
            }
            $!right = Set.new(@vls);
            for $!left.keys -> $vertex {
                for @(%!graph{$vertex}) -> $neighbour {
                        %!graph{$neighbour}.push: $vertex;
                }
            }

        }
        method !bfs() {
            my @layers;
            my SetHash $layer .= new;
            for $!left.keys -> $vertex {
                if not %!matching{$vertex}:exists {
                    $layer.set($vertex);
                }
            }
            @layers.push($layer);
            my SetHash $visited .= new;
            while True {
                #we take the most recent layer in the partitioning on every repeat
                my $thislayer = @layers.tail;
                my SetHash $new_layer .= new; # new list for subsequent layers
                for $thislayer.keys -> $vertex {
                    if $!left.EXISTS-KEY($vertex) {   # if true, we traverse unmatched edges to vertices in right
                        $visited.set($vertex);
                        for @(%!graph{$vertex}) -> $neighbour {
                        # check if the neighbour is not already visited
                        # check if vertex is matched or the edge between neighbour and vertex is not matched
                            if (not $visited.EXISTS-KEY($neighbour))
                                and ( (not %!matching.EXISTS-KEY($vertex)) or (  $neighbour !=== %!matching{$vertex}) ) {
                                $new_layer.set($neighbour);
                            }
                        }
                    } else {
                        $visited.set($vertex);
                        for @(%!graph{$vertex}) -> $neighbour {
                        # check if the neighbour is not already visited
                        # check if vertex is in the matching and if the edge between vertex and neighbour is matched
                            if (not $visited.EXISTS-KEY($neighbour))
                                and ( (%!matching.EXISTS-KEY($vertex))  and ($neighbour === %!matching{$vertex})) {
                                $new_layer.set($neighbour);
                            }
                        }
                    }
                }
                push @layers, $new_layer;# we add the new layer to the set of layers
                # if new_layer is empty, we have to break the BFS while loop....
                return @layers if $new_layer.elems == 0; # break
                # else, we terminate search at the first layer k where one or more free vertices in V are reached
                for $new_layer.keys {
                    if $!right.EXISTS-KEY($_) and not %!matching.EXISTS-KEY($_) {
                        return @layers;
                    }
                }
            }
        }
       # --------------------------------------------------------------------------------------------------------------
       # if we are able to collate these free vertices, we run DFS recursively on each of them
       # this algorithm finds a maximal set of vertex disjoint augmenting paths of length k (shortest path),
       # stores them in P and increments M...
       # --------------------------------------------------------------------------------------------------------------
        method !dfs(Any $v is copy,Int $index,@layers --> Bool) {
            #`[
             we recursively run dfs on each vertices in free_vertex,

             :param v: vertices in free_vertex
             :return: True if P is not empty (i.e., the maximal set of vertex-disjoint alternating path of length k)
             and false otherwise.
             ]
             if $index == 0 {
                 my @path = ($v);
                 while %!dfs_parent{$v} !=== $v {
                     @path.append(%!dfs_parent{$v});
                     $v = %!dfs_parent{$v};
                 }
                 @!dfs_paths.push(@path);
                 return True;
             }
             for @(%!graph{$v}) -> $neighbour {
                 if $neighbour ∈ @layers[$index - 1 ] {
                     next if %!dfs_parent.EXISTS-KEY($neighbour);
                     if ( $!left.EXISTS-KEY($neighbour) and ( (not %!matching.EXISTS-KEY($v)) or $neighbour !=== %!matching{$v} ) )
                         or
                     ( $!right.EXISTS-KEY($neighbour) and (%!matching.EXISTS-KEY($v) and $neighbour === %!matching{$v} )) {
                         %!dfs_parent{$neighbour} = $v;
                         return True if self!dfs($neighbour,$index - 1, @layers);
                     }
                 }
             }
             return False;
        }
        method maximum_matching(Bool $keys_only = False) {
            while True {
                my @layers = self!bfs();
                # we break out of the whole while loop if the most recent layer added to layers is empty
                # since if there are no vertices in the recent layer, then there is no way augmenting paths can be found
                my $last = @layers.tail;
                last if $last.elems == 0;
                my SetHash $free_vertex .= new;
                for $last.keys -> $vertex {
                    next if $vertex ∈ %!matching;
                    $free_vertex.set($vertex);
                }
                # the maximal set of vertex-disjoint augmenting path and parent dictionary
                # has to be cleared each time the while loop runs
                # self._dfs_paths.clear() - .clear() and .copy() attribute works for python 3.3 and above
                @!dfs_paths = ();
                %!dfs_parent = %();
                for $free_vertex.keys -> $vertex {
                    %!dfs_parent{$vertex} = $vertex;
                    self!dfs($vertex,@layers.end,@layers);
                }
                # if the set of paths is empty, nothing to add to the matching...break
                last if @!dfs_paths.elems == 0;
    
                # if not, we swap the matched and unmatched edges in the paths formed and add them to the existing matching.
                # the paths are augmenting implies the first and start vertices are free. Edges 1, 3, 5, .. are thus matched
                for @!dfs_paths -> @path {
                    for 0 .. @path.end -> $i {
                        if ($i % 2) == 0 {
                            %!matching{@path[$i]} = @path[$i+1];
                            %!matching{@path[$i+1]} = @path[$i];
                        }
                    }
                }
             }
           if $keys_only === True {
                for %!matching.keys -> $k {
                    %!matching{$k}:delete unless $!left.EXISTS-KEY($k);
                }
            }
            self!calculate_vertices();
        return %!matching; 
        }
        
        method get_graph {
            return %!graph_origin;
        }

        method !calculate_vertices() {
            my %inverted_mis{Any};
            for %!matching.kv -> $k,$v {
                %inverted_mis{$v} = $k;
            }
            $!alternated_paths .= new;
            for %!graph_origin.kv -> $k,$val {
                if not %!matching.EXISTS-KEY($k)  {
                    for @$val -> $v {
                        if %inverted_mis.EXISTS-KEY($v) {
                             $!alternated_paths.set(($k,$v,%inverted_mis{$v}));
                         }
                    }
                } 
           }
            my $K = ($!left ∖ $!alternated_paths.keys) ∪ ($!right ∩ $!alternated_paths.keys);
            $!vertices= ($!left.keys,$!right.keys) ∖ $K;
            return ($!alternated_paths,$!vertices)
        }
    }

