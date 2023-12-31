import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animal_shogi/domain/output/shogi_game_output.dart';
import 'package:animal_shogi/domain/repository/player_repository.dart';
import 'package:animal_shogi/entity/model/model.dart';
import 'package:animal_shogi/entity/rule/rule.dart';
import 'package:animal_shogi/presenter/game_presenter.dart';
import 'package:animal_shogi/state/player_state.dart';
import 'package:vector_math/vector_math.dart';

final shogiGameProvider = Provider(
  (ref) => ShogiGame(
    ref.read,
  ),
);

class ShogiGame {
  ShogiGame(this._read);
  final Reader _read;

  late final PlayerRepository playerRepository = _read(
    playerRepositoryProvider.notifier,
  );

  late final PlayerRepository rivalRepository = _read(
    rivalRepositoryProvider.notifier,
  );

  late final ShogiGameOutput gamePresenter = _read(
    shogiGamePresenterProvider,
  );

  /// 駒を取得
  /// [pieces]に[position]に配置された駒があるならば取得
  Piece? searchPiece({
    required Vector2 position,
    required List<Piece> pieces,
  }) {
    return pieces.firstWhereOrNull(
      (piece) => piece.position == position,
    );
  }

  void callCaptureProcess({
    required Piece newPiece,
    required List<Piece> pieces,
    required void Function(Piece piece) removePiece,
    required void Function(Piece piece) capturePiece,
  }) {
    final capturedPiece = searchPiece(
      position: newPiece.position!,
      pieces: pieces,
    );
    if (capturedPiece != null) {
      removePiece(capturedPiece);
      // 駒が成っているなら、成りを解除
      final demotedPiece = capturedPiece.demote() ?? capturedPiece;
      capturePiece(demotedPiece);
    }
  }

  /// ターンごとの判定
  /// [newPiece]はこのターンで移動した駒
  Future<void> update(Piece newPiece) async {
    final playerId = playerRepository.getId();
    // 駒の取得処理を実行
    if (newPiece.ownerId == playerId) {
      callCaptureProcess(
        newPiece: newPiece,
        pieces: rivalRepository.getPieces(),
        removePiece: (Piece piece) => rivalRepository.removePiece(
          piece: piece,
        ),
        capturePiece: (Piece piece) => playerRepository.addCapturedPiece(
          piece: piece,
        ),
      );
    } else {
      callCaptureProcess(
        newPiece: newPiece,
        pieces: playerRepository.getPieces(),
        removePiece: (Piece piece) => playerRepository.removePiece(
          piece: piece,
        ),
        capturePiece: (Piece piece) => rivalRepository.addCapturedPiece(
          piece: piece,
        ),
      );
    }
    // 勝敗判定
    final playerPieces = playerRepository.getPieces();
    final rivalPieces = rivalRepository.getPieces();
    final playerHasOusho = checkHasOusho(playerPieces);
    final rivalHasOusho = checkHasOusho(rivalPieces);

    // プレイヤーの負け
    if (!playerHasOusho) {
      await gamePresenter.showResultDialog(
        title: 'あなたの負け',
        content: '王を取られました',
      );
    }
    // 相手の負け
    if (!rivalHasOusho) {
      await gamePresenter.showResultDialog(
        title: 'あなたの勝ち',
        content: '王を取りました',
      );
    }
    // 二歩をチェック
    final playerGot2Fu = check2Fu(playerPieces);
    final rivalGot2Fu = check2Fu(rivalPieces);
    // プレイヤーの負け
    if (playerGot2Fu) {
      await gamePresenter.showResultDialog(
        title: 'あなたの負け',
        content: '二歩です',
      );
    }
    // 相手の負け
    if (rivalGot2Fu) {
      await gamePresenter.showResultDialog(
        title: 'あなたの勝ち',
        content: '相手が二歩でした',
      );
    }

    // 成りに関する処理
    final isAbleToPromote = checkIsAbleToPromote(
      piece: newPiece,
      playerId: playerId,
    );
    if (isAbleToPromote) {
      final isPromote = await gamePresenter.askPromoteOrNot();
      if (isPromote) {
        if (newPiece.ownerId == playerId) {
          playerRepository.promote(
            piece: newPiece,
          );
        }
        if (newPiece.ownerId != playerId) {
          rivalRepository.promote(
            piece: newPiece,
          );
        }
      }
    }
    // 次のターンへ
    final nextPlayerId = newPiece.ownerId == playerId ? rivalId : playerId;
    gamePresenter.turnEnd(
      nextPlayerId,
    );
  }
}

/// 駒の初期配置を取得
// 駒の初期配置を取得
List<Piece> getInitialPieces({
  required String ownerId,
  required bool isPlayer,
}) {
  final huhyoRowY = (isPlayer ? 2 : Board.colSize - 1 - 2).toDouble();
  final hisyakakuRowY = (isPlayer ? 1 : Board.colSize - 1 - 1).toDouble();
  final oushoRowY = (isPlayer ? 0 : Board.colSize - 1 - 0).toDouble();

  // 歩兵の行
  final huhyoRow = List.generate(
    Board.rowSize,
    (x) => Piece.hiyoko(
      // 歩兵をひよこに変更
      Vector2(
        x.toDouble(),
        huhyoRowY.toDouble(),
      ),
      ownerId,
    ),
  ).toList();

  // 飛車角の行
  final hisyakakuRow = [
    Piece.zou(
      // 角行をゾウに変更
      Vector2(
        isPlayer ? 1 : 7,
        hisyakakuRowY,
      ),
      ownerId,
    ),
    Piece.kirin(
      // 飛車をキリンに変更
      Vector2(
        isPlayer ? 7 : 1,
        hisyakakuRowY,
      ),
      ownerId,
    ),
  ];

  // 王将の行
  final oushoRow = [
    Piece.lion(
      // 王将をライオンに変更
      Vector2(
        isPlayer ? 4 : 4,
        oushoRowY,
      ),
      ownerId,
    ),
  ];
  return [...huhyoRow, ...hisyakakuRow, ...oushoRow];
}
