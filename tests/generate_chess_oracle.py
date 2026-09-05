"""Regenerate deterministic fixtures using python-chess 1.11.2, test-only.

python -m pip install --target work/oracle-python python-chess==1.999
python tests/generate_chess_oracle.py
"""
import json
from pathlib import Path
import random
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "work" / "oracle-python"))
import chess

rng = random.Random(20260905)
positions = []
starts = [chess.STARTING_FEN,
          "r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - 0 1",
          "8/2p5/3p4/KP5r/1R3p1k/8/4P1P1/8 w - - 0 1",
          "4k3/P7/8/8/8/8/7p/4K3 w - - 0 1"]
for game in range(16):
    board = chess.Board(starts[game % len(starts)])
    for ply in range(60):
        legal = sorted(board.legal_moves, key=lambda move: move.uci())
        if not legal:
            break
        selected = rng.choice(legal)
        record = {"fen": board.fen(en_passant="fen"),
                  "moves": {move.uci(): board.san(move) for move in legal},
                  "check": board.is_check(),
                  "selected": selected.uci()}
        board.push(selected)
        record["after"] = board.fen(en_passant="fen")
        positions.append(record)
output = {"oracle": "python-chess " + chess.__version__, "seed": 20260905,
          "positions": positions}
(ROOT / "tests" / "chess_oracle.json").write_text(json.dumps(output, indent=2) + "\n", encoding="utf-8")
print(f"Generated {len(positions)} oracle positions")
