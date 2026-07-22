* Encoding: UTF-8.

* -------------------------------------------------------------------------.
* 09b_early_window_roi_position_model.sps
*
* Purpose:
*   Analyze early ERP activity in the 0-180 ms window across all sequence
*   positions (A, B, C, D) and scalp regions.
*
*   This analysis tests whether early activity changes across sequence
*   position and whether any position-related effect differs across scalp
*   regions or stimulus domains.
*
* Input:
*   Wide-format ERP mean-amplitude table exported from ERPLAB for the
*   0-180 ms window.
*
* Required identifier:
*   ERPset
*
* Domains:
*   A = Algebraic
*   G = Graphical
*   L = Lexical
*
* Sequence positions:
*   A = first element
*   B = second element
*   C = third element
*   D = final completion element
*
* ROIs:
*   Occipital: O1/O2
*   Parietal:  P3/Pz/P4
*   Central:   C3/Cz/C4
*   Frontal:   F3/Fz/F4
*
* Position coding:
*   A = 0
*   B = 1
*   C = 2
*   D = 3
*
* -------------------------------------------------------------------------.


* -------------------------------------------------------------------------.
* 1) Compute ROI mean amplitudes for all domains and sequence positions.
* -------------------------------------------------------------------------.

* -------------------------.
* Algebraic domain.
* -------------------------.

COMPUTE A_Acon_Occ = MEAN(A_Acon_O1, A_Acon_O2).
COMPUTE A_Acon_Par = MEAN(A_Acon_P3, A_Acon_Pz, A_Acon_P4).
COMPUTE A_Acon_Cen = MEAN(A_Acon_C3, A_Acon_Cz, A_Acon_C4).
COMPUTE A_Acon_Fro = MEAN(A_Acon_F3, A_Acon_Fz, A_Acon_F4).

COMPUTE A_Bcon_Occ = MEAN(A_Bcon_O1, A_Bcon_O2).
COMPUTE A_Bcon_Par = MEAN(A_Bcon_P3, A_Bcon_Pz, A_Bcon_P4).
COMPUTE A_Bcon_Cen = MEAN(A_Bcon_C3, A_Bcon_Cz, A_Bcon_C4).
COMPUTE A_Bcon_Fro = MEAN(A_Bcon_F3, A_Bcon_Fz, A_Bcon_F4).

COMPUTE A_Ccon_Occ = MEAN(A_Ccon_O1, A_Ccon_O2).
COMPUTE A_Ccon_Par = MEAN(A_Ccon_P3, A_Ccon_Pz, A_Ccon_P4).
COMPUTE A_Ccon_Cen = MEAN(A_Ccon_C3, A_Ccon_Cz, A_Ccon_C4).
COMPUTE A_Ccon_Fro = MEAN(A_Ccon_F3, A_Ccon_Fz, A_Ccon_F4).

COMPUTE A_Dcon_Occ = MEAN(A_Dcon_O1, A_Dcon_O2).
COMPUTE A_Dcon_Par = MEAN(A_Dcon_P3, A_Dcon_Pz, A_Dcon_P4).
COMPUTE A_Dcon_Cen = MEAN(A_Dcon_C3, A_Dcon_Cz, A_Dcon_C4).
COMPUTE A_Dcon_Fro = MEAN(A_Dcon_F3, A_Dcon_Fz, A_Dcon_F4).


* -------------------------.
* Graphical domain.
* -------------------------.

COMPUTE G_Acon_Occ = MEAN(G_Acon_O1, G_Acon_O2).
COMPUTE G_Acon_Par = MEAN(G_Acon_P3, G_Acon_Pz, G_Acon_P4).
COMPUTE G_Acon_Cen = MEAN(G_Acon_C3, G_Acon_Cz, G_Acon_C4).
COMPUTE G_Acon_Fro = MEAN(G_Acon_F3, G_Acon_Fz, G_Acon_F4).

COMPUTE G_Bcon_Occ = MEAN(G_Bcon_O1, G_Bcon_O2).
COMPUTE G_Bcon_Par = MEAN(G_Bcon_P3, G_Bcon_Pz, G_Bcon_P4).
COMPUTE G_Bcon_Cen = MEAN(G_Bcon_C3, G_Bcon_Cz, G_Bcon_C4).
COMPUTE G_Bcon_Fro = MEAN(G_Bcon_F3, G_Bcon_Fz, G_Bcon_F4).

COMPUTE G_Ccon_Occ = MEAN(G_Ccon_O1, G_Ccon_O2).
COMPUTE G_Ccon_Par = MEAN(G_Ccon_P3, G_Ccon_Pz, G_Ccon_P4).
COMPUTE G_Ccon_Cen = MEAN(G_Ccon_C3, G_Ccon_Cz, G_Ccon_C4).
COMPUTE G_Ccon_Fro = MEAN(G_Ccon_F3, G_Ccon_Fz, G_Ccon_F4).

COMPUTE G_Dcon_Occ = MEAN(G_Dcon_O1, G_Dcon_O2).
COMPUTE G_Dcon_Par = MEAN(G_Dcon_P3, G_Dcon_Pz, G_Dcon_P4).
COMPUTE G_Dcon_Cen = MEAN(G_Dcon_C3, G_Dcon_Cz, G_Dcon_C4).
COMPUTE G_Dcon_Fro = MEAN(G_Dcon_F3, G_Dcon_Fz, G_Dcon_F4).


* -------------------------.
* Lexical domain.
* -------------------------.

COMPUTE L_Acon_Occ = MEAN(L_Acon_O1, L_Acon_O2).
COMPUTE L_Acon_Par = MEAN(L_Acon_P3, L_Acon_Pz, L_Acon_P4).
COMPUTE L_Acon_Cen = MEAN(L_Acon_C3, L_Acon_Cz, L_Acon_C4).
COMPUTE L_Acon_Fro = MEAN(L_Acon_F3, L_Acon_Fz, L_Acon_F4).

COMPUTE L_Bcon_Occ = MEAN(L_Bcon_O1, L_Bcon_O2).
COMPUTE L_Bcon_Par = MEAN(L_Bcon_P3, L_Bcon_Pz, L_Bcon_P4).
COMPUTE L_Bcon_Cen = MEAN(L_Bcon_C3, L_Bcon_Cz, L_Bcon_C4).
COMPUTE L_Bcon_Fro = MEAN(L_Bcon_F3, L_Bcon_Fz, L_Bcon_F4).

COMPUTE L_Ccon_Occ = MEAN(L_Ccon_O1, L_Ccon_O2).
COMPUTE L_Ccon_Par = MEAN(L_Ccon_P3, L_Ccon_Pz, L_Ccon_P4).
COMPUTE L_Ccon_Cen = MEAN(L_Ccon_C3, L_Ccon_Cz, L_Ccon_C4).
COMPUTE L_Ccon_Fro = MEAN(L_Ccon_F3, L_Ccon_Fz, L_Ccon_F4).

COMPUTE L_Dcon_Occ = MEAN(L_Dcon_O1, L_Dcon_O2).
COMPUTE L_Dcon_Par = MEAN(L_Dcon_P3, L_Dcon_Pz, L_Dcon_P4).
COMPUTE L_Dcon_Cen = MEAN(L_Dcon_C3, L_Dcon_Cz, L_Dcon_C4).
COMPUTE L_Dcon_Fro = MEAN(L_Dcon_F3, L_Dcon_Fz, L_Dcon_F4).

EXECUTE.


* -------------------------------------------------------------------------.
* 2) Convert from wide to long format.
*
* Order within each domain:
*   A_Occ A_Par A_Cen A_Fro
*   B_Occ B_Par B_Cen B_Fro
*   C_Occ C_Par C_Cen C_Fro
*   D_Occ D_Par D_Cen D_Fro
*
* Total cells:
*   3 domains x 4 positions x 4 ROIs = 48.
* -------------------------------------------------------------------------.

VARSTOCASES
  /MAKE Y FROM
    A_Acon_Occ A_Acon_Par A_Acon_Cen A_Acon_Fro
    A_Bcon_Occ A_Bcon_Par A_Bcon_Cen A_Bcon_Fro
    A_Ccon_Occ A_Ccon_Par A_Ccon_Cen A_Ccon_Fro
    A_Dcon_Occ A_Dcon_Par A_Dcon_Cen A_Dcon_Fro
    G_Acon_Occ G_Acon_Par G_Acon_Cen G_Acon_Fro
    G_Bcon_Occ G_Bcon_Par G_Bcon_Cen G_Bcon_Fro
    G_Ccon_Occ G_Ccon_Par G_Ccon_Cen G_Ccon_Fro
    G_Dcon_Occ G_Dcon_Par G_Dcon_Cen G_Dcon_Fro
    L_Acon_Occ L_Acon_Par L_Acon_Cen L_Acon_Fro
    L_Bcon_Occ L_Bcon_Par L_Bcon_Cen L_Bcon_Fro
    L_Ccon_Occ L_Ccon_Par L_Ccon_Cen L_Ccon_Fro
    L_Dcon_Occ L_Dcon_Par L_Dcon_Cen L_Dcon_Fro
  /INDEX = Cell(48)
  /KEEP = ERPset
  /NULL = KEEP.
EXECUTE.


* -------------------------------------------------------------------------.
* 3) Create Domain, SequencePosition, Position, ROI, and RegionOrdinal.
* -------------------------------------------------------------------------.

* Domain:
*   1 = Algebraic
*   2 = Graphical
*   3 = Lexical.

DO IF (Cell <= 16).
  COMPUTE Domain = 1.
ELSE IF (Cell <= 32).
  COMPUTE Domain = 2.
ELSE.
  COMPUTE Domain = 3.
END IF.


* Position within each domain.
* Each domain has 16 cells:
*   4 sequence positions x 4 ROIs.

COMPUTE PositionInDomain = MOD(Cell - 1, 16) + 1.


* SequencePosition:
*   1 = A
*   2 = B
*   3 = C
*   4 = D.

DO IF (PositionInDomain <= 4).
  COMPUTE SequencePosition = 1.
ELSE IF (PositionInDomain <= 8).
  COMPUTE SequencePosition = 2.
ELSE IF (PositionInDomain <= 12).
  COMPUTE SequencePosition = 3.
ELSE.
  COMPUTE SequencePosition = 4.
END IF.


* Ordinal position predictor:
*   A = 0
*   B = 1
*   C = 2
*   D = 3.

COMPUTE Position = SequencePosition - 1.


* ROI:
*   1 = Occipital
*   2 = Parietal
*   3 = Central
*   4 = Frontal.

COMPUTE ROI = MOD(Cell - 1, 4) + 1.


* Optional posterior-to-anterior region coding:
*   Occipital = 0
*   Parietal  = 1
*   Central   = 2
*   Frontal   = 3.

COMPUTE RegionOrdinal = ROI - 1.


VALUE LABELS Domain
  1 'Algebraic'
  2 'Graphical'
  3 'Lexical'.

VALUE LABELS SequencePosition
  1 'A'
  2 'B'
  3 'C'
  4 'D'.

VALUE LABELS ROI
  1 'Occipital'
  2 'Parietal'
  3 'Central'
  4 'Frontal'.

EXECUTE.


* -------------------------------------------------------------------------.
* 4) Main early-window ROI x Position model.
*
* This model tests whether early amplitude changes across sequence position
* and whether that change depends on scalp region and/or stimulus domain.
* -------------------------------------------------------------------------.

MIXED Y BY Domain ROI
  WITH Position
  /FIXED = Domain ROI Position Domain*ROI Domain*Position ROI*Position Domain*ROI*Position | SSTYPE(3)
  /METHOD = REML
  /RANDOM = Position | SUBJECT(ERPset) COVTYPE(VC)
  /EMMEANS = TABLES(ROI)
  /EMMEANS = TABLES(ROI) COMPARE(ROI) ADJ(BONFERRONI)
  /PRINT = SOLUTION TESTCOV.


* -------------------------------------------------------------------------.
* 5) Planned slope contrasts across ROIs.
*
* These contrasts test whether the position-related slope differs between
* selected scalp regions.
*
* ROI order:
*   1 = Occipital
*   2 = Parietal
*   3 = Central
*   4 = Frontal
* -------------------------------------------------------------------------.

MIXED Y BY Domain ROI
  WITH Position
  /FIXED = Domain ROI Position Domain*ROI Domain*Position ROI*Position Domain*ROI*Position | SSTYPE(3)
  /METHOD = REML
  /RANDOM = Position | SUBJECT(ERPset) COVTYPE(VC)
  /PRINT = SOLUTION TESTCOV
  /LMATRIX 'Occipital vs Parietal slope'
    Position*ROI 1 -1 0 0
  /LMATRIX 'Occipital vs Central slope'
    Position*ROI 1 0 -1 0
  /LMATRIX 'Occipital vs Frontal slope'
    Position*ROI 1 0 0 -1
  /LMATRIX 'Parietal vs Central slope'
    Position*ROI 0 1 -1 0
  /LMATRIX 'Parietal vs Frontal slope'
    Position*ROI 0 1 0 -1
  /LMATRIX 'Central vs Frontal slope'
    Position*ROI 0 0 1 -1.


* -------------------------------------------------------------------------.
* 6) Optional ordinal posterior-to-anterior model across all positions.
*
* Use this only if you want to test whether the early posterior-to-anterior
* gradient changes across sequence position.
* -------------------------------------------------------------------------.

MIXED Y BY Domain
  WITH Position RegionOrdinal
  /FIXED = Domain Position RegionOrdinal
           Domain*Position Domain*RegionOrdinal Position*RegionOrdinal
           Domain*Position*RegionOrdinal | SSTYPE(3)
  /METHOD = REML
  /RANDOM = Position | SUBJECT(ERPset) COVTYPE(VC)
  /PRINT = SOLUTION TESTCOV.