"use strict";

/*****************************************************************************/
/** Minesweeper tile */
/*****************************************************************************/

function Tile(opts = {}) {
  _.defaults(opts, {isMine: false, isFlagged: false, isCovered: true});
  this.row       = opts.row;
  this.column    = opts.column;
  this.isMine    = opts.isMine;
  this.isFlagged = opts.isFlagged;
  this.isCovered = true;
  this.adjacent  = [];
}

Tile.prototype.flag = function () {
  if (this.isUncovered()) {
    throw 'already uncovered';
  }
  this.flag = !this.flag;
};

Tile.prototype.uncover = function () {
  if (this.isUncovered()) {
    throw 'already uncovered';
  }
  this.isCovered = false;
};

Tile.prototype.isUncovered = function () {
  return !isCovered;
};

Tile.prototype.htmlDisplay = function () {
  if (this.isMine) {
    return "\u{1F4A3}";
  } else {
    return ".";
  }
};

Tile.prototype.reset = function () {
  this.isCovered = true;
  this.isFlagged = false;
};

/*****************************************************************************/
/** Minesweeper board */
/*****************************************************************************/

function Board(opts = {}) {
  this.rows    = _.defaults(opts, {rows: 20}).rows;
  this.columns = _.defaults(opts, {columns: opts.rows}).columns;
  this.mines   = _.defaults(opts, {mines: opts.rows * opts.columns / 8}).mines;
  this.tiles   = [];
  this.initialize();
}

Board.prototype.initialize = function () {
  // Build our tile grid
  var tilesInit = [];
  var i, j;
  for (i = 0; i < this.rows * this.columns; i++) {
    tilesInit[i] = new Tile({isMine: i < this.mines});
  }
  // Randomize mines locations
  tilesInit = _.shuffle(tilesInit);
  // Place mines in grid
  var tile;
  for (i = 0; i < this.rows; i++) {
    this.tiles[i] = [];
    for (j = 0; j < this.columns; j++) {
      tile = tilesInit.pop();
      tile.row = i;
      tile.column = j;
      this.tiles[i][j] = tile;
    }
  }
  // Determine adjacency
  var self = this;
  this.allTiles(function (tile, row, col) {
    tile.adjacent = self.adjacentTiles(row, col);
  });
};

Board.prototype.htmlDisplay = function () {
  var html = "";
  for (var i = 0; i < this.rows; i++) {
    html += "<div class='tile_row'>\n";
    for (var j = 0; j < this.columns; j++) {
      html += "<div class='tile' data-row='" + i + "' data-column='" + j + "'>" + this.tiles[i][j].htmlDisplay() + "</div>"
    }
    html += "</div>\n";
  }
  return html;
};

Board.prototype.adjacentTiles = function (row, col) {
  if (!this.isInBounds(row, col)) {
    return [];
  }
  // NW N NE
  // W  +  E
  // SW S SE
  var offsets = [
    [-1, -1], [-1, 0], [-1, 1],
    [0, -1], [0, 1],
    [1, -1], [1, 0], [1, 1]
  ];
  var adjacent = [];
  var self = this;
  offsets.forEach(function (pos) {
    var tile = self.tile(row + pos[0], col + pos[1]);
    if (tile) {
      adjacent.push(tile);
    }
  });
  return adjacent;
};

Board.prototype.reset = function () {
  this.allTiles.forEach(function (tile) {
    tile.reset();
  });
};

Board.prototype.allTiles = function (callback) {
  this.tiles.forEach(function (tileRow, row) {
    tileRow.forEach(function (tile, col) {
      callback(tile, row, col);
    });
  });
};

Board.prototype.tile = function (row, col) {
  if (this.isInBounds(row, col)) {
    return this.tiles[row][col];
  }
};

Board.prototype.isInBounds = function (row, col) {
  return row > -1 && row < this.rows && col > -1 && col < this.columns;
};
