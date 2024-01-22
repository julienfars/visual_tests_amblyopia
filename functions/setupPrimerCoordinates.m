function [ARROWLT, ARROWRT, ARROWLB, ARROWRB, penWidthPixels] = setupPrimerCoordinates(HC1)
    % Set up primer arrow coordinates.

    % Extract corner coordinates
    LeftTopCorner = HC1(1:2, 3);
    RightTopCorner = HC1(1:2, 4);
    LeftBottomCorner = HC1(1:2, 5);
    RightBottomCorner = HC1(1:2, 6);

    % Calculate arrow coordinates
    ARROWLT_1 = [LeftTopCorner(1); LeftTopCorner(2); LeftTopCorner(1)+20; LeftTopCorner(2)+5];
    ARROWLT_2 = [LeftTopCorner(1); LeftTopCorner(2); LeftTopCorner(1)+5; LeftTopCorner(2)+20];
    ARROWLT = [ARROWLT_1, ARROWLT_2];

    ARROWRT_1 = [RightTopCorner(1)-20+90; RightTopCorner(2); RightTopCorner(1)+90; RightTopCorner(2)+5];
    ARROWRT_2 = [RightTopCorner(1)-5+90; RightTopCorner(2); RightTopCorner(1)+90; RightTopCorner(2)+20];
    ARROWRT = [ARROWRT_1, ARROWRT_2];

    ARROWLB_1 = [LeftBottomCorner(1); LeftBottomCorner(2)-5+45; LeftBottomCorner(1)+20; LeftBottomCorner(2)+45];
    ARROWLB_2 = [LeftBottomCorner(1); LeftBottomCorner(2)-20+45; LeftBottomCorner(1)+5; LeftBottomCorner(2)+45];
    ARROWLB = [ARROWLB_1, ARROWLB_2];

    ARROWRB_1 = [RightBottomCorner(1)-20+90; RightBottomCorner(2)-5+45; RightBottomCorner(1)+90; RightBottomCorner(2)+45];
    ARROWRB_2 = [RightBottomCorner(1)-5+90; RightBottomCorner(2)-20+45; RightBottomCorner(1)+90; RightBottomCorner(2)+45];
    ARROWRB = [ARROWRB_1, ARROWRB_2];

    % Define pen width
    penWidthPixels = 6;
end