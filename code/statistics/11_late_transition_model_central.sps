* Encoding: UTF-8.

* -------------------------------------------------------------------------.
* 11_late_transition_model_central.sps
*
* Purpose:
*   Compute adjacent position differences in the 250-500 ms window and test
*   whether the size of the increase differs across sequence transitions
*   within the central ROI.
*
* Input:
*   Wide-format ERP mean-amplitude table exported from ERPLAB.
*
* Required variables:
*   ERPset
*   A_Acon_C3 A_Acon_C4 A_Acon_Cz
*   A_Bcon_C3 A_Bcon_C4 A_Bcon_Cz
*   A_Ccon_C3 A_Ccon_C4 A_Ccon_Cz
*   A_Dcon_C3 A_Dcon_C4 A_Dcon_Cz
*   G_Acon_C3 G_Acon_C4 G_Acon_Cz
*   G_Bcon_C3 G_Bcon_C4 G_Bcon_Cz
*   G_Ccon_C3 G_Ccon_C4 G_Ccon_Cz
*   G_Dcon_C3 G_Dcon_C4 G_Dcon_Cz
*   L_Acon_C3 L_Acon_C4 L_Acon_Cz
*   L_Bcon_C3 L_Bcon_C4 L_Bcon_Cz
*   L_Ccon_C3 L_Ccon_C4 L_Ccon_Cz
*   L_Dcon_C3 L_Dcon_C4 L_Dcon_Cz
*
* Domains:
*   A = Algebraic
*   G = Graphical
*   L = Lexical
*
* Sequence positions:
*   A, B, C, D
*
* Transitions:
*   AB = B - A
*   BC = C - B
*   CD = D - C
*
* Model:
*   Linear mixed-effects model with Domain, Transition, and their
*   interaction as fixed effects, and random intercepts by participant.
* -------------------------------------------------------------------------.


* -------------------------------------------------------------------------.
* 1) Compute central ROI mean amplitudes: C3/Cz/C4.
* -------------------------------------------------------------------------.

* Algebraic.
COMPUTE A_Acon_Cen = MEAN(A_Acon_C3, A_Acon_C4, A_Acon_Cz).
COMPUTE A_Bcon_Cen = MEAN(A_Bcon_C3, A_Bcon_C4, A_Bcon_Cz).
COMPUTE A_Ccon_Cen = MEAN(A_Ccon_C3, A_Ccon_C4, A_Ccon_Cz).
COMPUTE A_Dcon_Cen = MEAN(A_Dcon_C3, A_Dcon_C4, A_Dcon_Cz).

* Graphical.
COMPUTE G_Acon_Cen = MEAN(G_Acon_C3, G_Acon_C4, G_Acon_Cz).
COMPUTE G_Bcon_Cen = MEAN(G_Bcon_C3, G_Bcon_C4, G_Bcon_Cz).
COMPUTE G_Ccon_Cen = MEAN(G_Ccon_C3, G_Ccon_C4, G_Ccon_Cz).
COMPUTE G_Dcon_Cen = MEAN(G_Dcon_C3, G_Dcon_C4, G_Dcon_Cz).

* Lexical.
COMPUTE L_Acon_Cen = MEAN(L_Acon_C3, L_Acon_C4, L_Acon_Cz).
COMPUTE L_Bcon_Cen = MEAN(L_Bcon_C3, L_Bcon_C4, L_Bcon_Cz).
COMPUTE L_Ccon_Cen = MEAN(L_Ccon_C3, L_Ccon_C4, L_Ccon_Cz).
COMPUTE L_Dcon_Cen = MEAN(L_Dcon_C3, L_Dcon_C4, L_Dcon_Cz).

EXECUTE.


* -------------------------------------------------------------------------.
* 2) Compute adjacent transition differences.
* -------------------------------------------------------------------------.

* Algebraic transitions.
COMPUTE A_AB = A_Bcon_Cen - A_Acon_Cen.
COMPUTE A_BC = A_Ccon_Cen - A_Bcon_Cen.
COMPUTE A_CD = A_Dcon_Cen - A_Ccon_Cen.

* Graphical transitions.
COMPUTE G_AB = G_Bcon_Cen - G_Acon_Cen.
COMPUTE G_BC = G_Ccon_Cen - G_Bcon_Cen.
COMPUTE G_CD = G_Dcon_Cen - G_Ccon_Cen.

* Lexical transitions.
COMPUTE L_AB = L_Bcon_Cen - L_Acon_Cen.
COMPUTE L_BC = L_Ccon_Cen - L_Bcon_Cen.
COMPUTE L_CD = L_Dcon_Cen - L_Ccon_Cen.

EXECUTE.


* -------------------------------------------------------------------------.
* 3) Convert transition differences from wide to long format.
* -------------------------------------------------------------------------.

VARSTOCASES
  /MAKE Delta FROM
    A_AB A_BC A_CD
    G_AB G_BC G_CD
    L_AB L_BC L_CD
  /INDEX = Cell(9)
  /KEEP = ERPset
  /NULL = KEEP.

EXECUTE.


* -------------------------------------------------------------------------.
* 4) Create Domain and Transition factors.
* -------------------------------------------------------------------------.

STRING Domain (A12).
STRING Transition (A2).

DO IF Cell = 1.
  COMPUTE Domain = "Algebraic".
  COMPUTE Transition = "AB".
ELSE IF Cell = 2.
  COMPUTE Domain = "Algebraic".
  COMPUTE Transition = "BC".
ELSE IF Cell = 3.
  COMPUTE Domain = "Algebraic".
  COMPUTE Transition = "CD".
ELSE IF Cell = 4.
  COMPUTE Domain = "Graphical".
  COMPUTE Transition = "AB".
ELSE IF Cell = 5.
  COMPUTE Domain = "Graphical".
  COMPUTE Transition = "BC".
ELSE IF Cell = 6.
  COMPUTE Domain = "Graphical".
  COMPUTE Transition = "CD".
ELSE IF Cell = 7.
  COMPUTE Domain = "Lexical".
  COMPUTE Transition = "AB".
ELSE IF Cell = 8.
  COMPUTE Domain = "Lexical".
  COMPUTE Transition = "BC".
ELSE IF Cell = 9.
  COMPUTE Domain = "Lexical".
  COMPUTE Transition = "CD".
END IF.

EXECUTE.


* -------------------------------------------------------------------------.
* 5) Linear mixed-effects model.
* -------------------------------------------------------------------------.

MIXED Delta BY Domain Transition
  /FIXED = Domain Transition Domain*Transition | SSTYPE(3)
  /METHOD = REML
  /RANDOM = INTERCEPT | SUBJECT(ERPset) COVTYPE(VC)
  /EMMEANS = TABLES(Transition) COMPARE(Transition) ADJ(BONFERRONI)
  /EMMEANS = TABLES(Domain*Transition)
  /PRINT = SOLUTION TESTCOV.