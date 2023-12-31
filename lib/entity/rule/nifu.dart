import 'package:animal_shogi/entity/model/model.dart';

/// 盤面に二歩が存在するかチェック
bool check2Fu(List<Piece> pieces) {
  final xs = pieces
      .where(
        (piece) => piece.name == '歩',
      )
      .map(
        (huhyo) => huhyo.position!.x,
      )
      .toList();
  final xsLength = xs.length;
  final uniqueXsLength = xs.toSet().toList().length;
  return xsLength != uniqueXsLength;
}
