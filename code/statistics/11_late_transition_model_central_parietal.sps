* Encoding: UTF-8.

* -------------------------------------------------------------------------.
* 11_late_transition_model_central.sps
*
* Purpose:
*   Analyze adjacent amplitude increases in the late 250-500 ms window
*   within the central ROI.
*
* ROI:
*   Central = C3/Cz/C4
*
* Transitions:
*   AB = B - A
*   BC = C - B
*   CD = D - C
*
* -------------------------------------------------------------------------.


* -------------------------------------------------------------------------.
* 1) Compute central ROI mean amplitudes for each domain and position.
* -------------------------------------------------------------------------.

* Algebraic.
COMPUTE A_Acon_Cen = MEAN(A_Acon_C3, A_Acon_Cz, A_Acon_C4).
COMPUTE A_Bcon_Cen = MEAN(A_Bcon_C3, A_Bcon_Cz, A_Bcon_C4).
COMPUTE A_Ccon_Cen = MEAN(A_Ccon_C3, A_Ccon_Cz, A_Ccon_C4).
COMPUTE A_Dcon_Cen = MEAN(A_Dcon_C3, A_Dcon_Cz, A_Dcon_C4).

* Graphical.
COMPUTE G_Acon_Cen = MEAN(G_Acon_C3, G_Acon_Cz, G_Acon_C4).
COMPUTE G_Bcon_Cen = MEAN(G_Bcon_C3, G_Bcon_Cz, G_Bcon_C4).
COMPUTE G_Ccon_Cen = MEAN(G_Ccon_C3, G_Ccon_Cz, G_Ccon_C4).
COMPUTE G_Dcon_Cen = MEAN(G_Dcon_C3, G_Dcon_Cz, G_Dcon_C4).

* Lexical.
COMPUTE L_Acon_Cen = MEAN(L_Acon_C3, L_Acon_Cz, L_Acon_C4).
COMPUTE L_Bcon_Cen = MEAN(L_Bcon_C3, L_Bcon_Cz, L_Bcon_C4).
COMPUTE L_Ccon_Cen = MEAN(L_Ccon_C3, L_Ccon_Cz, L_Ccon_C4).
COMPUTE L_Dcon_Cen = MEAN(L_Dcon_C3, L_Dcon_Cz, L_Dcon_C4).

EXECUTE.


* -------------------------------------------------------------------------.
* 2) Compute adjacent transition differences.
* -------------------------------------------------------------------------.

* Algebraic.
COMPUTE A_AB_Cen = A_Bcon_Cen - A_Acon_Cen.
COMPUTE A_BC_Cen = A_Ccon_Cen - A_Bcon_Cen.
COMPUTE A_CD_Cen = A_Dcon_Cen - A_Ccon_Cen.

* Graphical.
COMPUTE G_AB_Cen = G_Bcon_Cen - G_Acon_Cen.
COMPUTE G_BC_Cen = G_Ccon_Cen - G_Bcon_Cen.
COMPUTE G_CD_Cen = G_Dcon_Cen - G_Ccon_Cen.

* Lexical.
COMPUTE L_AB_Cen = L_Bcon_Cen - L_Acon_Cen.
COMPUTE L_BC_Cen = L_Ccon_Cen - L_Bcon_Cen.
COMPUTE L_CD_Cen = L_Dcon_Cen - L_Ccon_Cen.

EXECUTE.


* -------------------------------------------------------------------------.
* 3) Convert transition differences from wide to long format.
*
* Order:
*   A_AB_Cen A_BC_Cen A_CD_Cen
*   G_AB_Cen G_BC_Cen G_CD_Cen
*   L_AB_Cen L_BC_Cen L_CD_Cen
*
* Total cells:
*   3 domains x 3 transitions = 9.
* -------------------------------------------------------------------------.

VARSTOCASES
  /MAKE Delta FROM
    A_AB_Cen A_BC_Cen A_CD_Cen
    G_AB_Cen G_BC_Cen G_CD_Cen
    L_AB_Cen L_BC_Cen L_CD_Cen
  /INDEX = Cell(9)
  /KEEP = ERPset
  /NULL = KEEP.

EXECUTE.


* -------------------------------------------------------------------------.
* 4) Create Domain and Transition factors.
* -------------------------------------------------------------------------.

* Domain:
*   1 = Algebraic
*   2 = Graphical
*   3 = Lexical.

DO IF (Cell <= 3).
  COMPUTE Domain = 1.
ELSE IF (Cell <= 6).
  COMPUTE Domain = 2.
ELSE.
  COMPUTE Domain = 3.
END IF.


* Transition:
*   1 = AB
*   2 = BC
*   3 = CD.

COMPUTE Transition = MOD(Cell - 1, 3) + 1.


VALUE LABELS Domain
  1 'Algebraic'
  2 'Graphical'
  3 'Lexical'.

VALUE LABELS Transition
  1 'AB'
  2 'BC'
  3 'CD'.

EXECUTE.


* -------------------------------------------------------------------------.
* 5) Main central transition model.
*
* Tests whether adjacent amplitude increases differ across transitions and
* stimulus domains within the central ROI.
* -------------------------------------------------------------------------.

MIXED Delta BY Domain Transition
  /FIXED = Domain Transition Domain*Transition | SSTYPE(3)
  /METHOD = REML
  /RANDOM = INTERCEPT | SUBJECT(ERPset) COVTYPE(VC)
  /EMMEANS = TABLES(Transition) COMPARE(Transition) ADJ(BONFERRONI)
  /EMMEANS = TABLES(Domain*Transition)
  /PRINT = SOLUTION TESTCOV.