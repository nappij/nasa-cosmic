�Z Q�:�  DUMMY VARIABLE FOR CHAIN TO COMPSIZE g SF�333� m
 � � �"                    LAMINAT2      Revised 7/13/86" � � � �"       ANALYSIS OF SYMMETRIC LAMINATE USING A- AND D-MATRIX" �< � �@ � ?A �   INPUT DESCRIPTION OF LAYUP GEOMETRY AND MATERIAL PROPERTIES EB � eF �"ENTER NUMBER OF PLIES ";N �M � TH(N),T(N),E1(N),E2(N),G(N),V1(N),V2(N),C1(N),C2(N),TR(N),FL(N),FT(N),S(N),X1(N),X2(N),X5(N),X6(N),S1(N),S2(N),S6(N),F1(N),F2(N),F3(N)  Z � I� � N _ � Hd � "ENTER PLY NO. STARTING WITH NO.1 AT BOTTOM OF LAMINATE ";I sn � "ENTER PLY ORIENTATION (DEG) ";TH(I) �x � "ENTER PLY THICKNESS (IN) ";T(I) �� � "ENTER E11 (MSI) ";E1(I) �� � "ENTER E22 (MSI) ";E2(I) �� � "ENTER G12 (MSI) ";G(I) � � "ENTER V12 ";V1(I) \� :�� INPUT "ENTER PLY C.T.E. IN MAJOR DIRECTION (E-6*IN/IN/DEG.F) ";C1(I) �� :�� INPUT "ENTER PLY C.T.E. IN TRANSVERSE DIRECTION (E-6*IN/IN/DEG. F ";C2(I) �� � I �� H� �� � I� � N �� E1(I)�E1(I)� $t� �� E2(I)�E2(I)� $t� � G(I)�G(I)� $t� (� V2(I)�V1(I)�E2(I)�E1(I) >� C1(I)�C1(I)��7m T� C2(I)�C2(I)��7m Z� � ~� �   TOTAL THICKNESS OF LAMINATE �� � �� H�H�T(I) �� � I �� � �� �   CALCULATE STIFFNESS TERMS �� � �� A1�:A2�:A3�:A4�:A5�:A6�:NX�:NY�:NS� 8� D1�:D2�:D3�:D4�:D5�:D6�:L1�:L2�:L3�:L4�:L5�:L6� D� Z1��H� R� � J� � N oQ1�E1(J)�(�V1(J)�V2(J)) �Q2�E2(J)�(�V1(J)�V2(J)) �Q3�V2(J)�E1(J)�(�V1(J)�V2(J)) �� ��   CALCULATE TRANSFORMED STIFFNESS TERMS �� �"TR(J)�TH(J)��.e� ,M1���(TR(J)) !6M2���(TR(J)) 2@T1�Q3��G(J) KJT2�Q1�Q2��Q3��G(J) _TT3�Q1�Q2��G(J) s^T4�Q1�Q3��G(J) �hT5�Q3�Q2��G(J) �rB1�Q1�M1���T1�M1��M2��Q2�M2� �|B4�Q1�M2���T1�M1��M2��Q2�M1� ��B6�T2�M1��M2��G(J)�(M1��M2�) �B2�T3�M1��M2��Q3�(M1��M2�) 8�B3�T4�M1��M2�T5�M1�M2� U�B5�T4�M1�M2��T5�M2�M1� [�� |��   PRINT Q-BAR FOR EACH PLY ��� ��:�� PRINT ��:�� PRINT"Q-BAR MATRIX FOR PLY NO. ";J ��:�� PRINT USING" ##.###^^^^";B1;B2;B3 �:�� PRINT USING" ##.###^^^^";B2;B4;B5 9�:�� PRINT USING" ##.###^^^^";B3;B5;B6 ?�� `��   CALCULATE A-MATRIX TERMS f�� x�A1�A1�B1�T(J) ��A2�A2�B2�T(J) ��A3�A3�B3�T(J) ��A4�A4�B4�T(J) ��A5�A5�B5�T(J) ��A6�A6�B6�T(J) ��� ��    CALCULATE TRANSFORMED PLY C.T.E. �� )�:�� CX=C1(J)*M1^2+C2(J)*M2^2 J�:�� CY=C1(J)*M2^2+C2(J)*M1^2 q�:�� CS=2*M1*M2*C1(J)-2*M1*M2*C2(J) w�� ��� CALCULATE THERMAL FORCES PER DEGREE F ��� �:�� NX=NX+B1*T(J)*CX+B2*T(J)*CY+B3*T(J)*CS :�� NY=NY+B2*T(J)*CX+B4*T(J)*CY+B5*T(J)*CS 6:�� NS=NS+B3*T(J)*CX+B5*T(J)*CY+B6*T(J)*CS E Z2�Z1�T(J) K"� g$�    CALCULATE B-MATRIX m&� ~(T2�Z2��Z1� �*T3�Z2��Z1� �,L1�L1�B1�T2� �.L2�L2�B2�T2� �0L3�L3�B3�T2� �2L4�L4�B4�T2� �4L5�L5�B5�T2� �6L6�L6�B6�T2� :� <�    CALCULATE D-MATRIX #>� 5@D1�D1�B1�T3� GBD2�D2�B2�T3� YDD3�D3�B3�T3� kFD4�D4�B4�T3� }HD5�D5�B5�T3� �JD6�D6�B6�T3� �NZ1�Z2 �U� J �V:�� PRINT �W:�� PRINT"Nx/DT (LB/IN/F)=";NX,"Ny/DT (LB/IN/F)=";NY,"Nxy/DT (LB/IN/F)=";NS X� !Y�   INVERT THE A-MATRIX 'Z� 9\T6�A4�A6�A5� L^T7�A2�A5�A3�A4 _`T8�A2�A6�A3�A5 xbT9�A1�T6�A2�T8�A3�T7 �dP1�T6�T9 �fP2��T8�T9 �hP3�T7�T9 �jP4�(A1�A6�A3�)�T9 �lP5�(�A1�A5�A3�A2)�T9 �nP6�(A1�A4�A2�)�T9 ��� �� INVERT THE D-MATRIX �� �U6�D4�D6�D5� 2�U7�D2�D5�D3�D4 E�U8�D2�D6�D3�D5 ^�U9�D1�U6�D2�U8�D3�U7 k�R1�U6�U9 y�R2��U8�U9 ��R3�U7�U9 ��R4�(D1�D6�D3�)�U9 ��R5�(�D1�D5�D3�D2)�U9 ��R6�(D1�D4�D2�)�U9 ��� ���   CALCULATE EFFECTIVE LAMINATE C.T.E. �� +�:�� AX=(A4*NX-A2*NY)/(A1*A4-A2^2) Q�:�� AY=(A1*NY-A2*NX)/(A1*A4-A2^2) b�:�� AS=NS/A6 h�� ��� � "TOTAL LAMINATE THICKNESS (IN)=##.###";H �� �� ��   LAMINATE PROPERTIES �� �EX�(A1�A4�A2�)�(H�A4) � EY�(A1�A4�A2�)�(H�A1) 
*V3�A2�A4 4V4�A2�A1 #>GX�A6�H jH�"   Ex(PSI)" �) "Ey(PSI)" �) "Vxy" �() "Vyx" �4) "Gxy(PSI)" �R� � "  ##.###^^^^";EX,EY,V3,V4,GX �\:�� PRINT �f:�� PRINT "C.T.E. IN THE X-DIRECTION=";AX;"IN/IN/DEG. F"  p:�� PRINT "C.T.E. IN THE Y-DIRECTION=";AY;"IN/IN/DEG. F" T z:�� PRINT "SHEAR C.T.E. IN XY-PLANE=";AS;"IN/IN/DEG. F" Z �� � ��"THE A-MATRIX IS:" �$) "THE D-MATRIX IS:" � �� � " ##.###^^^^";A1;A2;A3,D1;D2;D3 � �� � " ##.###^^^^";A2;A4;A5,D2;D4;D5 !�� � " ##.###^^^^";A3;A5;A6,D3;D5;D6 !�� K!�� "THE INVERTED A-MATRIX IS:" �$) "THE INVERTED D-MATRIX IS:" s!�� � " ##.###^^^^";P1;P2;P3,R1;R2;R3 �!�� � " ##.###^^^^";P2;P4;P5,R2;R4;R5 �!�� � " ##.###^^^^";P3;P5;P6,R3;R5;R6 �!�� �!��"THE B-MATRIX IS:"  "�� � " ##.###^^^^";L1;L2;L3 "�� � " ##.###^^^^";L2;L4;L5 >"�� � " ##.###^^^^";L3;L5;L6 D"�� �"��"WARNING!  B-MATRIX IS ASSUMED TO BE ZERO IN STRAIN CALCULATIONS" �"�� �"�� "ENTER NORMAL FORCE IN X-DIRECTION PER INCH OF WIDTH (LB/IN) ";NX !#�� "ENTER NORMAL FORCE IN Y-DIRECTION PER INCH OF WIDTH (LB/IN) ";NY f#�� "ENTER SHEAR FORCE IN X-Y PLANE PER INCH OF WIDTH (LB/IN) ";NS l#�� �#� "ENTER BENDING MOMENT IN X-Z PLANE PER INCH OF WIDTH (IN-LB/IN) ";MX $� "ENTER BENDING MOMENT IN Y-Z PLANE PER INCH OF WIDTH (IN-LB/IN) ";MY A$� "ENTER TWISTING MOMENT PER INCH OF WIDTH (IN-LB/IN) ";MS G$� k$�    CALCULATE LAMINATE STRAINS q$ � �$$SX�P1�NX�P2�NY�P3�NS �$.SY�P2�NX�P4�NY�P5�NS �$8SS�P3�NX�P5�NY�P6�NS �$B� �$L�    TRANSFORM LAMINATE STRAINS TO PLY STRAINS �$V� 	%`� L� � N %jX1(L)���(TR(L))� 5%tX2(L)���(TR(L))� K%~X5(L)�X1(L)�X2(L) m%�X6(L)�(��(TR(L)))�(��(TR(L))) �%�S1(L)�SX�X1(L)�SY�X2(L)�SS�X6(L) �%�S2(L)�SX�X2(L)�SY�X1(L)�SS�X6(L) �%�S6(L)��SX�X6(L)�SY�X6(L)�SS�X5(L)� :��   TENSOR STRAIN &�S6(L)��S6(L) :��    ENGINEERING STRAIN %&�� W&��    CALCULATE ALLOWABLE STRAINS FOR EACH PLY ]&�� c&�� i&�� &�� "FOR PLY NO.";L �&�� "ENTER ULT. ALLOWABLE STRESS IN 1-DIRECTION (KSI) ";FL(L) �&�� "ENTER ULT. ALLOWABLE STRESS IN 2-DIRECTION (KSI) ";FT(L) B'�� "ENTER ULT. ALLOWABLE SHEAR STRESS IN 1-2 PLANE (KSI) ";S(L) Y'�FL(L)�FL(L)���SF p'�FT(L)�FT(L)���SF �'�S(L)�S(L)���SF �'�F1(L)�FL(L)�E1(L) �'�F2(L)�FT(L)�E2(L) �'�F3(L)�S(L)�G(L) �'�� �' �    STRAIN OUTPUT FOR EACH PLY �'
� �'� +(�"PLY NO. ";L,"   THICKNESS=";T(L);"INCHES" W((�"ANGULAR ORIENTATION=";TH(L);"DEGREES" �(<�"E11=";E1(L);"PSI","E22=";E2(L);"PSI" �(F�"G12=";G(L);"PSI","V12=";V1(L) �(P�"IN 1-DIRECTION:  ALLOWABLE STRAIN=";F1(L);"  ACTUAL STRAIN=";S1(L) 8)Z�"IN 2-DIRECTION:  ALLOWABLE STRAIN=";F2(L);"  ACTUAL STRAIN=";S2(L) �)d�"IN 1-2 PLANE:    ALLOWABLE STRAIN=";F3(L);"  ACTUAL STRAIN=";S6(L) �)n� L �)o� �)p�    CALCULATE OVERALL LAMINATE STRAINS �)q� �)x� �)��"LAMINATE STRAIN IN X-DIRECTION=";SX *��"LAMINATE STRAIN IN Y-DIRECTION=";SY I*��"LAMINATE SHEAR STRAIN IN X=Y PLANE=";SS O*�� �*��    CALCULATE LAMINATE CENTER PLANE CURVATURE �*�� �*�KX�R1�MX�R2�MY�R3�MS �*�KY�R2�MX�R4�MY�R5�MS �*�KS�R3�MX�R5�MY�R6�MS �*�� +��"CENTER PLANE CURVATURE ABOUT X-AXIS (1/IN)=";KX E+��"CENTER PLANE CURVATURE ABOUT Y-AXIS (1/IN)=";KY v+��"TWISTING DEFORMATION CURVATURE (1/IN)=";KS |+�� �+�� "WANT OUTPUT SENT TO PRINTER? (Y/N) ";L$ �+�� L$��"Y" � L$��"y" � � �+��  ,�� � "TOTAL LAMINATE THICKNESS (IN)=##.###";H ,�� M,��"   Ex(PSI)" �) "Ey(PSI)" �) "Vxy" �() "Vyx" �4) "Gxy(PSI)" s,�� � "  ##.###^^^^";EX,EY,V3,V4,GX y,�� �,��"THE A-MATRIX IS:" �$) "THE D-MATRIX IS:" �,� � " ##.###^^^^";A1;A2;A3,D1;D2;D3 �,� � " ##.###^^^^";A2;A4;A5,D2;D4;D5 !-� � " ##.###^^^^";A3;A5;A6,D3;D5;D6 '-� j-� "THE INVERTED A-MATRIX IS:" �$) "THE INVERTED D-MATRIX IS:" �-� � " ##.###^^^^";P1;P2;P3,R1;R2;R3 �-!� � " ##.###^^^^";P2;P4;P5,R2;R4;R5 �-&� � " ##.###^^^^";P3;P5;P6,R3;R5;R6 �-+�  .0�"THE B-MATRIX IS:" .5� � " ##.###^^^^";L1;L2;L3 >.:� � " ##.###^^^^";L2;L4;L5 ].?� � " ##.###^^^^";L3;L5;L6 c.D� �.I� "WARNING!  B-MATRIX ASSUMED TO BE ZERO IN STRAIN CALCULATIONS" �.X� �.b�"NORMAL FORCE IN X-DIRECTION PER INCH OF WIDTH (LB/IN)=";NX 0/l�"NORMAL FORCE IN Y-DIRECTION PER INCH OF WIDTH (LB/IN)=";NY n/v�"SHEAR FORCE IN X-Y PLANE PER INCH OF WIDTH (LB/IN)=";NS t/x� �/z�"BENDING MOMENT IN X-Z PLANE PER INCH OF WIDTH (IN-LB/IN)=";MX �/|�"BENDING MOMENT IN Y-Z PLANE PER INCH OF WIDTH (IN-LB/IN)=";MY 40~�"TWISTING MOMENT PER INCH OF WIDTH (IN-LB/IN)=";MS B0�� L� � N H0�� y0��"PLY NO. ";L,"    THICKNESS=";T(L);"INCHES" �0��"ANGULAR ORIENTATION=";TH(L);"DEGREES" �0��"E11=";E1(L);"PSI","E22=";E2(L);"PSI" �0��"G12=";G(L);"PSI","V12=";V1(L) =1��"IN 1-DIRECTION:  ALLOWABLE STRAIN=";F1(L);"  ACTUAL STRAIN=";S1(L) �1��"IN 2-DIRECTION:  ALLOWABLE STRAIN=";F2(L);"  ACTUAL STRAIN=";S2(L) �1��"IN 1-2 PLANE:    ALLOWABLE STRAIN=";F3(L);"  ACTUAL STRAIN=";S6(L) �1�� L �1�� 2��"LAMINATE STRAIN IN X-DIRECTION=";SX 12�"LAMINATE STRAIN IN Y-DIRECTION=";SY _2�"LAMINATE SHEAR STRAIN IN X=Y PLANE=";SS e2� �2�"CENTER PLANE CURVATURE ABOUT X-AXIS (1/IN)=";KX �2�"CENTER PLANE CURVATURE ABOUT Y-AXIS (1/IN)=";KY 3�"TWISTING DEFORMATION CURVATURE (1/IN)=";KS 3� #3 � " END OF 'LAMINAT2'" )3*� /3�� S3��"END OF SUBROUTINE 'LAMINAT2'" Y3�� i3�� Q� � � �3��� "B:COMPSIZE",�& �3��   