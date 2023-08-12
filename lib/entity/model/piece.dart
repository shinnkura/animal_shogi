import 'package:animal_shogi/entity/model/model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vector_math/vector_math.dart';

part 'piece.freezed.dart';

// 移動方向(x,y)
final _up = Vector2(0, 1);
final _down = Vector2(0, -1);
final _right = Vector2(1, 0);
final _left = Vector2(-1, 0);
final _upRight = Vector2(1, 1);
final _upLeft = Vector2(-1, 1);
final _downRight = Vector2(1, -1);
final _downLeft = Vector2(-1, -1);

// 移動可能な量(x,y,移動できる回数)
final _upOne = Movement(direction: _up);
final _upRightOne = Movement(direction: _upRight);
final _rightOne = Movement(direction: _right);
final _downRightOne = Movement(direction: _downRight);
final _downOne = Movement(direction: _down);
final _downLeftOne = Movement(direction: _downLeft);
final _leftOne = Movement(direction: _left);
final _upLeftOne = Movement(direction: _upLeft);

final _upToEnd = Movement(direction: _up, count: Board.rowSize);
final _upRightToEnd = Movement(direction: _upRight, count: Board.rowSize);
final _rightToEnd = Movement(direction: _right, count: Board.rowSize);
final _downRightToEnd = Movement(direction: _downRight, count: Board.rowSize);
final _downToEnd = Movement(direction: _down, count: Board.rowSize);
final _downLeftToEnd = Movement(direction: _downLeft, count: Board.rowSize);
final _leftToEnd = Movement(direction: _left, count: Board.rowSize);
final _upLeftToEnd = Movement(direction: _upLeft, count: Board.rowSize);

final _keimaUpRight = Movement(
  direction: Vector2(1, 2),
  count: 1,
);
final _keimaUpLeft = Movement(
  direction: Vector2(-1, 2),
  count: 1,
);

// 駒の動きを定義

// ライオン
const lion = 'ラ';
final _lionMovableDirections = [
  _upOne,
  _upRightOne,
  _rightOne,
  _downRightOne,
  _downOne,
  _downLeftOne,
  _leftOne,
  _upLeftOne,
];

// ゾウ
const zou = 'ゾ';
final _zouMovableDirections = [
  _upRightOne,
  _downRightOne,
  _downLeftOne,
  _upLeftOne,
];

// キリン
const kirin = 'キ';
final _kirinMovableDirections = [
  _upOne,
  _rightOne,
  _downOne,
  _leftOne,
];

// ひよこ
const hiyoko = 'ひ';
final _hiyokoMovableDirections = [
  _upOne,
];

// にわとり（ひよこの成り駒）
const niwatori = 'に';
final _niwatoriMovableDirections = [
  _upOne,
  _upRightOne,
  _rightOne,
  _downRightOne,
  _downOne,
  _downLeftOne,
  _leftOne,
  _upLeftOne,
];

// 駒の移動
@freezed
class Movement with _$Movement {
  const factory Movement({
    required Vector2 direction,
    @Default(1) int count,
    // required Direction movableDirection,
  }) = _Movement;
  const Movement._();
}

// キー割り当ても必要
@freezed
abstract class Piece implements _$Piece {
  factory Piece({
    required String name,
    required List<Movement> movableDirections,
    required String ownerId,
    Vector2? position,
  }) = _Piece;
  Piece._();
  factory Piece.lion(
    Vector2 position,
    String ownerId,
  ) =>
      Piece(
        name: lion,
        movableDirections: _lionMovableDirections,
        position: position,
        ownerId: ownerId,
      );
  factory Piece.zou(
    Vector2 position,
    String ownerId,
  ) =>
      Piece(
        name: zou,
        movableDirections: _zouMovableDirections,
        position: position,
        ownerId: ownerId,
      );
  factory Piece.kirin(
    Vector2 position,
    String ownerId,
  ) =>
      Piece(
        name: kirin,
        movableDirections: _kirinMovableDirections,
        position: position,
        ownerId: ownerId,
      );
  factory Piece.hiyoko(
    Vector2 position,
    String ownerId,
  ) =>
      Piece(
        name: hiyoko,
        movableDirections: _hiyokoMovableDirections,
        position: position,
        ownerId: ownerId,
      );
  factory Piece.niwatori(
    Vector2 position,
    String ownerId,
  ) =>
      Piece(
        name: niwatori,
        movableDirections: _niwatoriMovableDirections,
        position: position,
        ownerId: ownerId,
      );

  /// 成りで何に成るか
  Piece? promote() {
    if (name == hiyoko) {
      return Piece.niwatori(position!, ownerId);
    }
    return null;
  }

  /// 成りを解除
  Piece? demote() {
    if (name == niwatori) {
      return Piece.hiyoko(position!, ownerId);
    }
    return null;
  }

  /// 成った駒か
  bool isPromoted() {
    switch (name) {
      case niwatori:
        return true;
    }
    return false;
  }
}
