%Criação da Tabela
createBoard(Board) :- length(Row, 7),  maplist(=('-'), Row),
                         length(Board, 6), maplist(=(Row), Board).

%Construção da Tabela na Tela
printIndices :- write('  0   1   2   3   4   5   6'), nl.

printTopBottomBar :- write('+---+---+---+---+---+---+---+'), nl.

printBoard([]) :- printTopBottomBar.
printBoard([Row|Tail]) :- printTopBottomBar, printRow(Row), nl,
                         printBoard(Tail).

%Dividir os elementos das listas(rows) para ficarem separados por '|'
printRow([]) :- write('|').
printRow([Head|Tail]) :- write('| '), write(Head), write(' '), printRow(Tail).
showBoard(Board) :- printIndices,
                    printBoard(Board), !.

%Lógica if empty (se for chamado numa função e não for vazio, ele sai da função e vai para a próxima do mesmo nome)
isEmpty(Board, RowIdx, ColIdx) :- 
    nth0(RowIdx, Board, Row), 
    nth0(ColIdx, Row, Value), 
    Value = '-'.

%Escreve a peça na posição ao pegar a linha da tabela, a coluna/elemento da linha e devolve uma nova tabela com a peça escrita
setPiece(Board, RowIdx, ColIdx, Value, NewBoard) :-
    nth0(RowIdx, Board, OldRow, OtherRows),
    nth0(ColIdx, OldRow, _OldCell, RowRest),
    nth0(ColIdx, NewRow, Value, RowRest),
    nth0(RowIdx, NewBoard, NewRow, OtherRows).

%Primeiro caso do if, se a posição estiver vazia, escreve a peça e devolve a nova tabela
playPiece(Board, RowIdx, ColIdx, Value, NewBoard) :-
    isEmpty(Board, RowIdx, ColIdx),
    setPiece(Board, RowIdx, ColIdx, Value, NewBoard), !.

%Segundo caso do if, vai passar para aqui quando isEmpty falhar, e falha se o RowIdx for 0, ou seja não pode subir mais
playPiece(Board, RowIdx, ColIdx, Value, NewBoard) :-
    RowIdx > 0,
    NewRowIdx is RowIdx - 1,
    playPiece(Board, NewRowIdx, ColIdx, Value, NewBoard).

%Terceiro caso do if, coluna está cheia e falha
playPiece(_Board, _RowIdx, _ColIdx, _Value, _NewBoard) :-
    write('Column is full!'), nl, fail.

%Função principal para jogar uma peça, começa a procurar da linha 5 (última linha pois vai de 0 a 5, cima a baixo)
play(Board, Col, Value, NewBoard) :-
    playPiece(Board, 5, Col, Value, NewBoard).

%Função para pegar o valor de uma célula específica
get_cell(Board, Row, Col, Value) :-
    Row >= 0, Row < 6,
    Col >= 0, Col < 7,
    nth0(Row, Board, R),
    nth0(Col, R, Value).

%Função para encontrar a linha onde a peça foi colocada 
find_row(Board, Col, Player, Row) :-
    nth0(Row, Board, R),
    nth0(Col, R, Player).


%. Função recursiva genérica para contar peças numa direção
count_direction(Board, Row, Col, Player, DRow, DCol, Count) :-
    NextRow is Row + DRow,
    NextCol is Col + DCol,
    get_cell(Board, NextRow, NextCol, Player), !,
    count_direction(Board, NextRow, NextCol, Player, DRow, DCol, TailCount),
    Count is TailCount + 1.

count_direction(_, _, _, _, _, _, 0).

%Verifica as linhas
check_horizontal(Board, Row, Col, Player) :-
    count_direction(Board, Row, Col, Player, 0, -1, Left),
    count_direction(Board, Row, Col, Player, 0, +1, Right),
    Total is Left + 1 + Right,
    Total >= 4.

%Verifica as colunas
check_vertical(Board, Row, Col, Player) :-
    count_direction(Board, Row, Col, Player, +1, 0, Down),
    % não precisa subir, peças são empilhadas
    Total is Down + 1,
    Total >= 4.

%Verifica as diagonais(↖ + ↘)
check_diag1(Board, Row, Col, Player) :-
    count_direction(Board, Row, Col, Player, -1, -1, UpLeft),
    count_direction(Board, Row, Col, Player, +1, +1, DownRight),
    Total is UpLeft + 1 + DownRight,
    Total >= 4.
%Verifica as diagonais(↗ + ↙)
check_diag2(Board, Row, Col, Player) :-
    count_direction(Board, Row, Col, Player, -1, +1, UpRight),
    count_direction(Board, Row, Col, Player, +1, -1, DownLeft),
    Total is UpRight + 1 + DownLeft,
    Total >= 4.
%Verifica se houve vitória em qualquer direção
check_win(Board, Row, Col, Player) :-
    check_horizontal(Board, Row, Col, Player);
    check_vertical(Board, Row, Col, Player);
    check_diag1(Board, Row, Col, Player);
    check_diag2(Board, Row, Col, Player).


%Testar a função play
testPlay :-
    createBoard(Board),
    play(Board, 3, 'X', Board1),
    showBoard(Board1),
    play(Board1, 3, 'O', Board2),
    showBoard(Board2),
    play(Board2, 3, 'X', Board3),
    showBoard(Board3).

%Testar a função de vitória horizontal
test_horizontal_win :-
    createBoard(B0),
    play(B0, 0, 'X', B1),
    play(B1, 1, 'X', B2),
    play(B2, 2, 'X', B3),
    play(B3, 3, 'X', B4),
    find_row(B4, 3, 'X', Row),
    ( check_win(B4, Row, 3, 'X') ->
        writeln('Horizontal OK!')
    ;   writeln('Horizontal FAILED!')
    ),
    showBoard(B4).

%Testar a função de vitória vertical
test_vertical_win :-
    createBoard(B0),
    play(B0, 2, 'O', B1),
    play(B1, 2, 'O', B2),
    play(B2, 2, 'O', B3),
    play(B3, 2, 'O', B4),
    find_row(B4, 2, 'O', Row),
    ( check_win(B4, Row, 2, 'O') ->
        writeln('Vertical OK!')
    ;   writeln('Vertical FAILED!')
    ),
    showBoard(B4).

%Teste: Diagonal \ (↘)
test_diag1_win :-
    createBoard(B0),

    play(B0, 3, 'X', B1),

    play(B1, 2, 'O', B2),
    play(B2, 2, 'X', B3),

    play(B3, 1, 'O', B4),
    play(B4, 1, 'O', B5),
    play(B5, 1, 'X', B6),

    play(B6, 0, 'O', B7),
    play(B7, 0, 'O', B8),
    play(B8, 0, 'O', B9),
    play(B9, 0, 'X', B10),

    find_row(B10, 0, 'X', Row),

    ( check_diag1(B10, Row, 0, 'X') ->
        writeln('Diagonal / OK!')
    ;   writeln('Diagonal / FAILED!')
    ),
    showBoard(B10).

%Teste: Diagonal / (↗)
test_diag2_win :-
    createBoard(B0),

    play(B0, 0, 'X', B1),
    
    play(B1, 1, 'O', B2),
    play(B2, 1, 'X', B3),
    
    play(B3, 2, 'O', B4),
    play(B4, 2, 'O', B5),
    play(B5, 2, 'X', B6),

    play(B6, 3, 'O', B7),
    play(B7, 3, 'O', B8),
    play(B8, 3, 'O', B9),
    play(B9, 3, 'X', B10),

    find_row(B10, 3, 'X', Row),

    ( check_diag2(B10, Row, 3, 'X') ->
        writeln('Diagonal \\ OK!')
    ;   writeln('Diagonal \\ FAILED!')
    ),
    showBoard(B10).

%Roda os testes ao mesmo tempo
run_all_tests :-
    test_horizontal_win,
    test_vertical_win,
    test_diag1_win,
    test_diag2_win.
