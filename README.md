# README

A vt100 console display-based Minesweeper in Ruby. Board is using ANSI escape sequences and Unicode, so you'll need to have
a terminal capable of displaying both.

To play, from command line:

```bash
$ ruby -r ./lib/minesweeper -e Minesweeper::Game.run 
```

To run the solver:

```bash
$ ruby -r ./lib/minesweeper -e Minesweeper::Solver.run
```

## Benchmarks

```
$ ruby -r ./lib/minesweeper -e 'Minesweeper::Solver.run(tries: 1000)'
wins: 670, losses: 330, took: 0.0349 sec
$ ruby -r ./lib/minesweeper -e 'Minesweeper::Solver.run(tries: 10_000)'
wins: 6768, losses: 3232, took: 0.3485 sec
$ ruby -r ./lib/minesweeper -e 'Minesweeper::Solver.run(tries: 100_000)'
wins: 66922, losses: 33078, took: 3.5274 sec
```

## TODOs

* Improve the solver (currently at ~67% win rate)
* More tests!
* Fully implement a JavaScript version, partially completed in `site`

# License

Copyright 2016, Micah Jaffe (micah.jaffe@gmail.com)
 
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
