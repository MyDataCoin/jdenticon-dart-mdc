import './config.dart';
import './colortheme.dart';
import './graphics.dart';
import './shapes.dart';
import './svg_renderer.dart';
import './transform.dart';

class IconGenerator {
  String _hash;
  SvgRenderer _renderer;
  double _padding;
  double _size;
  double _x;
  double _y;

  double cell;
  num hue;
  List<String> availableColors;
  List<int> selectedColorIndexes = [];
  int index = 0;
  Graphics graphics;

  IconGenerator(SvgRenderer renderer, String hash, double x, double y,
      double size, double padding, Config config) {
    this._renderer = renderer;
    this._hash = hash;

    this._padding = padding != null ? (size * padding).floorToDouble() : 0.0;
    this._size = size - (this._padding * 2.0);

    this.cell = (this._size / 4.0).floorToDouble();

    this._x = x +
        (this._padding + this._size / 2.0 - this.cell * 2.0).floorToDouble();
    this._y = y +
        (this._padding + this._size / 2.0 - this.cell * 2.0).floorToDouble();

    this.hue = int.parse(hash.substring(hash.length-7), radix: 16) / 0xffffff;
    this.availableColors = colorTheme(hue.toDouble(), config);
    this.graphics = Graphics(renderer);

    for (int i = 0; i < 3; i++) {
      this.index = int.parse(hash.substring(8 + i, 9 + i), radix: 16) % this.availableColors.length;
      if (isDuplicate([0, 4]) || // Disallow dark gray and dark color combo
          isDuplicate([2, 3])) {
        // Disallow light gray and light color combo
        this.index = 1;
      }
      this.selectedColorIndexes.add(this.index);
    }

    // Sides
    renderShape(0, Shapes.outer, 2, 3, [
      [1, 0],
      [2, 0],
      [2, 3],
      [1, 3],
      [0, 1],
      [3, 1],
      [3, 2],
      [0, 2]
    ]);
    // Corners
    renderShape(1, Shapes.outer, 4, 5, [
      [0, 0],
      [3, 0],
      [3, 3],
      [0, 3]
    ]);
    // Center
    renderShape(2, Shapes.center, 1, null, [
      [1, 1],
      [2, 1],
      [2, 2],
      [1, 2]
    ]);
    this._renderer.finish();
  }

  bool isDuplicate(List values) {
    if (values != null && values.indexOf(this.index) >= 0) {
      for (int i = 0; i < values.length; i++) {
        if (this.selectedColorIndexes.indexOf(values[i]) >= 0) {
          return true;
        }
      }
    }
    return false;
  }

  void renderShape(int colorIndex, List<Function> shapes, int index, int rotationIndex, List<List<int>> positions) {
    int r = rotationIndex != null ? int.parse(this._hash.substring(rotationIndex, rotationIndex + 1), radix: 16) : 0;
    Function shape = shapes[int.parse(this._hash.substring(index, index + 1), radix: 16) % shapes.length];
    
    this._renderer.beginShape(availableColors[selectedColorIndexes[colorIndex]]);
    for (int i = 0; i < positions.length; i++) {
      this.graphics.transform = Transform(
        this._x + positions[i][0] * cell,
        this._y + positions[i][1] * cell,
        cell,
        ((r++ % 4).toDouble())
        );
        shape(this.graphics, cell, i);
    }
    this._renderer.endShape();
  }
}