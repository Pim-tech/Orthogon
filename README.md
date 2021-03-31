

1. Fix your RAKULIB env variable or any other setting so that raku can access your lib/ directory

2. You need a 316 * 81 (COLUMNS * LINES) terminal or pseudo terminal like xterm or so

3. run ./charcons.raku

The orthogon should display

Remained vertices after HopfKorp and Karp reduction are with chars '-' for horizontal vertices , '|' for vertical vertices.

The finall cuts lines are with chars '°' if thez start from right to left and chars '*'  if they start from left to right.


As a result, the presented Orthogon will be divided into rectangles  of any composition of border/remained vertices/cuts and this is the fewest number of rectangles.


The goal is now to get the list of rectangles in order to feel them.


=======
# Orthogon
