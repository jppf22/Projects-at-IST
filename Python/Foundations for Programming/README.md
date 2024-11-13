# Minesweeper CLI-version

Simple CLI Minesweeper game, where, after initial setup, the player repeatdely:
- picks a coordinate
- chooses wether to sweep position (`L`) or to place/remove a flag (`M`)

## Usage
```python Minesweeper.py <last_col> <last_lin> <n_mines> <generator_dimension> <seed>```

Where:
- `last_col` (char) : the last column letter
- `last_lin`(int) : the last line integer
- `n_mines` (int)
- `generator_dimension` (32 or 64) : xorshift algorithm used to generate random numbers, 32 or 64 bit algorithm can be chosen
- `seed` (int)