* Encoding: UTF-8.

* -------------------------------------------------------------------------.
* 11_late_transition_model.sps
*
* Purpose:
*   Compute adjacent position differences in the 250-500 ms window and test
*   whether the size of the increase differs across sequence transitions.
*
* Input:
*   Wide-format ERP mean-amplitude table exported from ERPLAB.
*
* Required variables:
*   ERPset
*   A_Acon_P3 A_Acon_P4 A_Acon_Pz
*   A_Bcon_P3 A_Bcon_P4 A_Bcon_Pz
*   A_Ccon_P3 A_Ccon_P4 A_Ccon_Pz
*   A_Dcon_P3 A_Dcon_P4 A_Dcon_Pz
*   G_Acon_P3 G_Acon_P4 G_Acon_Pz
*   G_Bcon_P3 G_Bcon_P4 G_Bcon_Pz
*   G_Ccon_P3 G_Ccon_P4 G_Ccon_Pz
*   G_Dcon_P3 G_Dcon_P4 G_Dcon_Pz
*   L_Acon_P3 L_Acon_P4 L_Acon_Pz
*   L_Bcon_P3 L_Bcon_P4 L_Bcon_Pz
*   L_Ccon_P3 L_Ccon_P4 L_Ccon_Pz
*   L_Dcon_P3 L_Dcon_P4 L_Dcon_Pz
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
* 1) Compute parietal ROI mean amplitudes: P3/Pz/P4.
* -------------------------------------------------------------------------.

* Algebraic.
COMPUTE A_Acon_Par = MEAN(A_Acon_P3, A_Acon_P4, A_Acon_Pz).
COMPUTE A_Bcon_Par = MEAN(A_Bcon_P3, A_Bcon_P4, A_Bcon_Pz).
COMPUTE A_Ccon_Par = MEAN(A_Ccon_P3, A_Ccon_P4, A_Ccon_Pz).
COMPUTE A_Dcon_Par = MEAN(A_Dcon_P3, A_Dcon_P4, A_Dcon_Pz).

* Graphical.
COMPUTE G_Acon_Par = MEAN(G_Acon_P3, G_Acon_P4, G_Acon_Pz).
COMPUTE G_Bcon_Par = MEAN(G_Bcon_P3, G_Bcon_P4, G_Bcon_Pz).
COMPUTE G_Ccon_Par = MEAN(G_Ccon_P3, G_Ccon_P4, G_Ccon_Pz).
COMPUTE G_Dcon_Par = MEAN(G_Dcon_P3, G_Dcon_P4, G_Dcon_Pz).

* Lexical.
COMPUTE L_Acon_Par = MEAN(L_Acon_P3, L_Acon_P4, L_Acon_Pz).
COMPUTE L_Bcon_Par = MEAN(L_Bcon_P3, L_Bcon_P4, L_Bcon_Pz).
COMPUTE L_Ccon_Par = MEAN(L_Ccon_P3, L_Ccon_P4, L_Ccon_Pz).
COMPUTE L_Dcon_Par = MEAN(L_Dcon_P3, L_Dcon_P4, L_Dcon_Pz).

EXECUTE.


* -------------------------------------------------------------------------.
* 2) Compute adjacent transition differences.
* -------------------------------------------------------------------------.

* Algebraic transitions.
COMPUTE A_AB = A_Bcon_Par - A_Acon_Par.
COMPUTE A_BC = A_Ccon_Par - A_Bcon_Par.
COMPUTE A_CD = A_Dcon_Par - A_Ccon_Par.

* Graphical transitions.
COMPUTE G_AB = G_Bcon_Par - G_Acon_Par.
COMPUTE G_BC = G_Ccon_Par - G_Bcon_Par.
COMPUTE G_CD = G_Dcon_Par - G_Ccon_Par.

* Lexical transitions.
COMPUTE L_AB = L_Bcon_Par - L_Acon_Par.
COMPUTE L_BC = L_Ccon_Par - L_Bcon_Par.
COMPUTE L_CD = L_Dcon_Par - L_Ccon_Par.

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