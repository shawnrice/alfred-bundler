FasdUAS 1.101.10   ��   ��    k             l     ��  ��    &  # Current Alfred-Bundler version     � 	 	 @ #   C u r r e n t   A l f r e d - B u n d l e r   v e r s i o n   
  
 j     �� �� "0 bundler_version BUNDLER_VERSION  m        �   
 d e v e l      l     ��  ��    / )# Path to Alfred-Bundler's root directory     �   R #   P a t h   t o   A l f r e d - B u n d l e r ' s   r o o t   d i r e c t o r y      p       ������ 0 bundler_dir BUNDLER_DIR��        l     ����  r         b         b         l    	  ����   n     	 ! " ! 1    	��
�� 
psxp " l     #���� # I    �� $ %
�� .earsffdralis        afdr $ m     ��
�� afdrcusr % �� &��
�� 
rtyp & m    ��
�� 
ctxt��  ��  ��  ��  ��    m   	 
 ' ' � ( ( � L i b r a r y / A p p l i c a t i o n   S u p p o r t / A l f r e d   2 / W o r k f l o w   D a t a / a l f r e d . b u n d l e r -  o    ���� "0 bundler_version BUNDLER_VERSION  o      ���� 0 bundler_dir BUNDLER_DIR��  ��     ) * ) l     �� + ,��   + 0 *# Path to Alfred-Bundler's cache directory    , � - - T #   P a t h   t o   A l f r e d - B u n d l e r ' s   c a c h e   d i r e c t o r y *  . / . p     0 0 ������ 0 	cache_dir 	CACHE_DIR��   /  1 2 1 l   ' 3���� 3 r    ' 4 5 4 b    % 6 7 6 b     8 9 8 l    :���� : n     ; < ; 1    ��
�� 
psxp < l    =���� = I   �� > ?
�� .earsffdralis        afdr > m    ��
�� afdrcusr ? �� @��
�� 
rtyp @ m    ��
�� 
ctxt��  ��  ��  ��  ��   9 m     A A � B B � L i b r a r y / C a c h e s / c o m . r u n n i n g w i t h c r a y o n s . A l f r e d - 2 / W o r k f l o w   D a t a / a l f r e d . b u n d l e r - 7 o    $���� "0 bundler_version BUNDLER_VERSION 5 o      ���� 0 	cache_dir 	CACHE_DIR��  ��   2  C D C l     ��������  ��  ��   D  E F E l     ��������  ��  ��   F  G H G l      �� I J��   I   MAIN API FUNCTION     J � K K &   M A I N   A P I   F U N C T I O N   H  L M L l     ��������  ��  ��   M  N O N i     P Q P I      �������� 0 load_bundler  ��  ��   Q k     ' R R  S T S l      �� U V��   U � � Load `AlfredBundler.scpt` from the Alfred-Bundler directory as a script object. 
	If the Alfred-Bundler directory does not exist, install it (using `_bootstrap()`).

	:returns: the script object of `AlfredBundler.scpt`
	:rtype: ``script object``

	    V � W W�   L o a d   ` A l f r e d B u n d l e r . s c p t `   f r o m   t h e   A l f r e d - B u n d l e r   d i r e c t o r y   a s   a   s c r i p t   o b j e c t .   
 	 I f   t h e   A l f r e d - B u n d l e r   d i r e c t o r y   d o e s   n o t   e x i s t ,   i n s t a l l   i t   ( u s i n g   ` _ b o o t s t r a p ( ) ` ) . 
 
 	 : r e t u r n s :   t h e   s c r i p t   o b j e c t   o f   ` A l f r e d B u n d l e r . s c p t ` 
 	 : r t y p e :   ` ` s c r i p t   o b j e c t ` ` 
 
 	 T  X Y X l     �� Z [��   Z , &# Check if Alfred-Bundler is installed    [ � \ \ L #   C h e c k   i f   A l f r e d - B u n d l e r   i s   i n s t a l l e d Y  ] ^ ] Z      _ `���� _ >     a b a l     c���� c n     d e d I    �� f���� 0 _folder_exists   f  g�� g o    ���� 0 bundler_dir BUNDLER_DIR��  ��   e  f     ��  ��   b m    ��
�� boovtrue ` k     h h  i j i l   �� k l��   k  # install it if not    l � m m & #   i n s t a l l   i t   i f   n o t j  n�� n n    o p o I    �������� 0 
_bootstrap  ��  ��   p  f    ��  ��  ��   ^  q r q I   �� s��
�� .sysodelanull��� ��� nmbr s m     t t ?���������   r  u v u l   �� w x��   w ? 9# Path to `AlfredBundler.scpt` in Alfed-Bundler directory    x � y y r #   P a t h   t o   ` A l f r e d B u n d l e r . s c p t `   i n   A l f e d - B u n d l e r   d i r e c t o r y v  z { z r      | } | l    ~���� ~ b      �  o    ���� 0 bundler_dir BUNDLER_DIR � m     � � � � � 6 / b u n d l e r / A l f r e d B u n d l e r . s c p t��  ��   } o      ���� 0 
as_bundler   {  � � � l  ! !�� � ���   �  # Return script object    � � � � , #   R e t u r n   s c r i p t   o b j e c t �  ��� � L   ! ' � � I  ! &�� ���
�� .sysoloadscpt        file � o   ! "���� 0 
as_bundler  ��  ��   O  � � � l     ��������  ��  ��   �  � � � l      �� � ���   �   AUTO-DOWNLOAD BUNDLER     � � � � .   A U T O - D O W N L O A D   B U N D L E R   �  � � � l     ��������  ��  ��   �  � � � i    
 � � � I      �������� 0 
_bootstrap  ��  ��   � k     � � �  � � � l      �� � ���   � ` Z Check if bundler bash bundlet is installed and install it if not.

	:returns: ``None``

	    � � � � �   C h e c k   i f   b u n d l e r   b a s h   b u n d l e t   i s   i n s t a l l e d   a n d   i n s t a l l   i t   i f   n o t . 
 
 	 : r e t u r n s :   ` ` N o n e ` ` 
 
 	 �  � � � l     �� � ���   � " # Ask to install the Bundler    � � � � 8 #   A s k   t o   i n s t a l l   t h e   B u n d l e r �  � � � Q      � � � � n    � � � I    �������� 0 _install_confirmation  ��  ��   �  f     � R      ������
�� .ascrerr ****      � ****��  ��   � k     � �  � � � l   �� � ���   � 7 1# Cannot continue to install the bundler, so stop    � � � � b #   C a n n o t   c o n t i n u e   t o   i n s t a l l   t h e   b u n d l e r ,   s o   s t o p �  ��� � L     � � m    ��
�� boovfals��   �  � � � l   �� � ���   �  # Download the bundler    � � � � , #   D o w n l o a d   t h e   b u n d l e r �  � � � r    ) � � � J    ' � �  � � � b     � � � b     � � � m     � � � � � h h t t p s : / / g i t h u b . c o m / s h a w n r i c e / a l f r e d - b u n d l e r / a r c h i v e / � o    ���� "0 bundler_version BUNDLER_VERSION � m     � � � � �  . z i p �  ��� � b    % � � � b    # � � � m     � � � � � f h t t p s : / / b i t b u c k e t . o r g / s h a w n r i c e / a l f r e d - b u n d l e r / g e t / � o    "���� "0 bundler_version BUNDLER_VERSION � m   # $ � � � � �  . z i p��   � o      ���� 0 urls URLs �  � � � l  * *�� � ���   � @ :# Save Alfred-Bundler zipfile to this location temporarily    � � � � t #   S a v e   A l f r e d - B u n d l e r   z i p f i l e   t o   t h i s   l o c a t i o n   t e m p o r a r i l y �  � � � r   * 1 � � � b   * / � � � l  * - ����� � n   * - � � � 1   + -��
�� 
strq � o   * +���� 0 	cache_dir 	CACHE_DIR��  ��   � m   - . � � � � � , / i n s t a l l e r / b u n d l e r . z i p � o      ���� 0 _zipfile   �  � � � X   2 d ��� � � k   B _ � �  � � � r   B Q � � � l  B O ����� � I  B O�� ���
�� .sysoexecTEXT���     TEXT � b   B K � � � b   B I � � � b   B G � � � b   B E � � � m   B C � � � � � Z c u r l   - f s S L   - - c r e a t e - d i r s   - - c o n n e c t - t i m e o u t   5   � o   C D���� 0 _url   � m   E F � � � � �    - o   � o   G H���� 0 _zipfile   � m   I J � � � � �    & &   e c h o   $ ?��  ��  ��   � o      ���� 0 _status   �  ��� � Z  R _ � ����� � =  R W � � � o   R S���� 0 _status   � m   S V � � � � �  0 �  S   Z [��  ��  ��  �� 0 _url   � o   5 6���� 0 urls URLs �  �  � l  e e����   # # Could not download the file    � : #   C o u l d   n o t   d o w n l o a d   t h e   f i l e   Z  e }���� >  e j	 o   e f���� 0 _status  	 m   f i

 �  0 R   m y��
�� .ascrerr ****      � **** m   u x � N C o u l d   n o t   d o w n l o a d   b u n d l e r   i n s t a l l   f i l e ��~
� 
errn m   q t�}�} �~  ��  ��    l  ~ ~�|�|   L F# Ensure directory tree already exists for bundler to be moved into it    � � #   E n s u r e   d i r e c t o r y   t r e e   a l r e a d y   e x i s t s   f o r   b u n d l e r   t o   b e   m o v e d   i n t o   i t  n  ~ � I    ��{�z�{ 0 
_check_dir   �y o    ��x�x 0 bundler_dir BUNDLER_DIR�y  �z    f   ~   l  � ��w�w   ; 5# Unzip the bundler and move it to its data directory    �   j #   U n z i p   t h e   b u n d l e r   a n d   m o v e   i t   t o   i t s   d a t a   d i r e c t o r y !"! r   � �#$# b   � �%&% b   � �'(' b   � �)*) m   � �++ �,,  c d  * l  � �-�v�u- n   � �./. 1   � ��t
�t 
strq/ o   � ��s�s 0 	cache_dir 	CACHE_DIR�v  �u  ( m   � �00 �11 l ;   c d   i n s t a l l e r ;   u n z i p   - q o   b u n d l e r . z i p ;   m v   . / * / b u n d l e r  & l  � �2�r�q2 n   � �343 1   � ��p
�p 
strq4 o   � ��o�o 0 bundler_dir BUNDLER_DIR�r  �q  $ o      �n�n 0 _cmd  " 565 I  � ��m7�l
�m .sysoexecTEXT���     TEXT7 o   � ��k�k 0 _cmd  �l  6 898 l  � ��j:;�j  : Q K# Wait until bundler is fully unzipped and written to disk before finishing   ; �<< � #   W a i t   u n t i l   b u n d l e r   i s   f u l l y   u n z i p p e d   a n d   w r i t t e n   t o   d i s k   b e f o r e   f i n i s h i n g9 =>= r   � �?@? l  � �A�i�hA b   � �BCB o   � ��g�g 0 bundler_dir BUNDLER_DIRC m   � �DD �EE 6 / b u n d l e r / A l f r e d B u n d l e r . s c p t�i  �h  @ o      �f�f 0 
as_bundler  > FGF V   � �HIH I  � ��eJ�d
�e .sysodelanull��� ��� nmbrJ m   � �KK ?ə������d  I H   � �LL l  � �M�c�bM n  � �NON I   � ��aP�`�a 0 _path_exists  P Q�_Q o   � ��^�^ 0 
as_bundler  �_  �`  O  f   � ��c  �b  G RSR O  � �TUT I  � ��]V�\
�] .coredeloobj        obj V l  � �W�[�ZW c   � �XYX 4   � ��YZ
�Y 
psxfZ o   � ��X�X 0 	cache_dir 	CACHE_DIRY m   � ��W
�W 
alis�[  �Z  �\  U m   � �[[�                                                                                  MACS  alis    t  Macintosh HD               ����H+  ҍK
Finder.app                                                     ԲY�`�        ����  	                CoreServices    ���*      �`D    ҍKҍHҍG  6Macintosh HD:System: Library: CoreServices: Finder.app   
 F i n d e r . a p p    M a c i n t o s h   H D  &System/Library/CoreServices/Finder.app  / ��  S \�V\ L   � ��U�U  �V   � ]^] l     �T�S�R�T  �S  �R  ^ _`_ l     �Qab�Q  a ; 5# Function to get confirmation to install the bundler   b �cc j #   F u n c t i o n   t o   g e t   c o n f i r m a t i o n   t o   i n s t a l l   t h e   b u n d l e r` ded i    fgf I      �P�O�N�P 0 _install_confirmation  �O  �N  g k     �hh iji l      �Mkl�M  k � � Ask user for permission to install Alfred-Bundler. 
	Allow user to go to website for more information, or even to cancel download.

	:returns: ``True`` or raises Error

	   l �mmV   A s k   u s e r   f o r   p e r m i s s i o n   t o   i n s t a l l   A l f r e d - B u n d l e r .   
 	 A l l o w   u s e r   t o   g o   t o   w e b s i t e   f o r   m o r e   i n f o r m a t i o n ,   o r   e v e n   t o   c a n c e l   d o w n l o a d . 
 
 	 : r e t u r n s :   ` ` T r u e ` `   o r   r a i s e s   E r r o r 
 
 	j non l     �Lpq�L  p 0 *# Get path to workflow's `info.plist` file   q �rr T #   G e t   p a t h   t o   w o r k f l o w ' s   ` i n f o . p l i s t `   f i l eo sts r     	uvu b     wxw n    yzy I    �K�J�I�K 0 _pwd  �J  �I  z  f     x m    {{ �||  i n f o . p l i s tv o      �H�H 
0 _plist  t }~} l  
 
�G��G   5 /# Get name of workflow's from `info.plist` file   � ��� ^ #   G e t   n a m e   o f   w o r k f l o w ' s   f r o m   ` i n f o . p l i s t `   f i l e~ ��� r   
 ��� b   
 ��� b   
 ��� m   
 �� ��� T / u s r / l i b e x e c / P l i s t B u d d y   - c   ' P r i n t   : n a m e '   '� o    �F�F 
0 _plist  � m    �� ���  '� o      �E�E 0 _cmd  � ��� r    ��� I   �D��C
�D .sysoexecTEXT���     TEXT� o    �B�B 0 _cmd  �C  � o      �A�A 	0 _name  � ��� l   �@���@  � 6 0# Get workflow's icon, or default to system icon   � ��� ` #   G e t   w o r k f l o w ' s   i c o n ,   o r   d e f a u l t   t o   s y s t e m   i c o n� ��� r    #��� b    !��� n   ��� I    �?�>�=�? 0 _pwd  �>  �=  �  f    � m     �� ���  i c o n . p n g� o      �<�< 	0 _icon  � ��� r   $ ,��� n  $ *��� I   % *�;��:�; 0 _check_icon  � ��9� o   % &�8�8 	0 _icon  �9  �:  �  f   $ %� o      �7�7 	0 _icon  � ��� l  - -�6���6  � / )# Prepare explanation text for dialog box   � ��� R #   P r e p a r e   e x p l a n a t i o n   t e x t   f o r   d i a l o g   b o x� ��� r   - 6��� b   - 4��� b   - 2��� b   - 0��� o   - .�5�5 	0 _name  � m   . /�� ���   n e e d s   t o   i n s t a l l   a d d i t i o n a l   c o m p o n e n t s ,   w h i c h   w i l l   b e   p l a c e d   i n   t h e   A l f r e d   s t o r a g e   d i r e c t o r y   a n d   w i l l   n o t   i n t e r f e r e   w i t h   y o u r   s y s t e m . 
 
 Y o u   m a y   b e   a s k e d   t o   a l l o w   s o m e   c o m p o n e n t s   t o   r u n ,   d e p e n d i n g   o n   y o u r   s e c u r i t y   s e t t i n g s . 
 
 Y o u   c a n   d e c l i n e   t h i s   i n s t a l l a t i o n ,   b u t  � o   0 1�4�4 	0 _name  � m   2 3�� ��� �   m a y   n o t   w o r k   w i t h o u t   t h e m .   T h e r e   w i l l   b e   a   s l i g h t   d e l a y   a f t e r   a c c e p t i n g .� o      �3�3 	0 _text  � ��� l  7 7�2�1�0�2  �1  �0  � ��� r   7 Y��� n   7 W��� 1   S W�/
�/ 
bhit� l  7 S��.�-� I  7 S�,��
�, .sysodlogaskr        TEXT� o   7 8�+�+ 	0 _text  � �*��
�* 
btns� J   9 >�� ��� m   9 :�� ���  M o r e   I n f o� ��� m   : ;�� ���  C a n c e l� ��)� m   ; <�� ���  P r o c e e d�)  � �(��
�( 
dflt� m   ? @�'�' � �&��
�& 
appr� b   A D��� m   A B�� ���  S e t u p  � o   B C�%�% 	0 _name  � �$��#
�$ 
disp� 4   G M�"�
�" 
psxf� o   K L�!�! 	0 _icon  �#  �.  �-  � o      � �  0 	_response  � ��� l  Z Z����  � 0 *# If permission granted, continue download   � ��� T #   I f   p e r m i s s i o n   g r a n t e d ,   c o n t i n u e   d o w n l o a d� ��� Z  Z h����� =  Z _��� o   Z [�� 0 	_response  � m   [ ^�� ���  P r o c e e d� L   b d�� m   b c�
� boovtrue�  �  � ��� l  i i����  � 6 0# If more info requested, open webpage and error   � ��� ` #   I f   m o r e   i n f o   r e q u e s t e d ,   o p e n   w e b p a g e   a n d   e r r o r� ��� Z   i ������ =  i n��� o   i j�� 0 	_response  � m   j m�� ���  M o r e   I n f o� k   q ��� ��� O   q ��� I  w ~� �
� .GURLGURLnull��� ��� TEXT  m   w z � � h t t p s : / / g i t h u b . c o m / s h a w n r i c e / a l f r e d - b u n d l e r / w i k i / W h a t - i s - t h e - A l f r e d - B u n d l e r�  � m   q t�                                                                                  sevs  alis    �  Macintosh HD               ����H+  ҍKSystem Events.app                                              �U'�A��        ����  	                CoreServices    ���*      �A�9    ҍKҍHҍG  =Macintosh HD:System: Library: CoreServices: System Events.app   $  S y s t e m   E v e n t s . a p p    M a c i n t o s h   H D  -System/Library/CoreServices/System Events.app   / ��  � � R   � ��
� .ascrerr ****      � **** m   � � � F U s e r   l o o k e d   s o u g h t   m o r e   i n f o r m a t i o n �	�
� 
errn	 m   � ��� �  �  �  �  � 

 l  � ���   , &# If permission denied, stop and error    � L #   I f   p e r m i s s i o n   d e n i e d ,   s t o p   a n d   e r r o r � Z  � ��� =  � � o   � ��� 0 	_response   m   � � �  C a n c e l R   � ��

�
 .ascrerr ****      � **** m   � � � D U s e r   c a n c e l e d   b u n d l e r   i n s t a l l a t i o n �	�
�	 
errn m   � ��� �  �  �  �  e  l     ����  �  �    l     ����  �  �     l      � !"�   !   HELPER HANDLERS    " �## "   H E L P E R   H A N D L E R S    $%$ l     ��������  ��  ��  % &'& i    ()( I      �������� 0 _pwd  ��  ��  ) k     8** +,+ l      ��-.��  - � � Get path to "present working directory", i.e. the workflow's root directory.
	
	:returns: Path to this script's parent directory
	:rtype: ``string`` (POSIX path)

	   . �//J   G e t   p a t h   t o   " p r e s e n t   w o r k i n g   d i r e c t o r y " ,   i . e .   t h e   w o r k f l o w ' s   r o o t   d i r e c t o r y . 
 	 
 	 : r e t u r n s :   P a t h   t o   t h i s   s c r i p t ' s   p a r e n t   d i r e c t o r y 
 	 : r t y p e :   ` ` s t r i n g ` `   ( P O S I X   p a t h ) 
 
 	, 010 l     ��23��  2 = 7# Save default AS delimiters, and set delimiters to "/"   3 �44 n #   S a v e   d e f a u l t   A S   d e l i m i t e r s ,   a n d   s e t   d e l i m i t e r s   t o   " / "1 565 r     787 J     99 :;: n    <=< 1    ��
�� 
txdl= 1     ��
�� 
ascr; >��> m    ?? �@@  /��  8 J      AA BCB o      ���� 0 astid ASTIDC D��D n     EFE 1    ��
�� 
txdlF 1    ��
�� 
ascr��  6 GHG l   ��IJ��  I , &# Get POSIX path of script's directory   J �KK L #   G e t   P O S I X   p a t h   o f   s c r i p t ' s   d i r e c t o r yH LML r    /NON b    -PQP l   +R����R c    +STS n    )UVU 7   )��WX
�� 
citmW m   # %���� X m   & (������V l   Y����Y n    Z[Z 1    ��
�� 
psxp[ l   \����\ I   ��]��
�� .earsffdralis        afdr]  f    ��  ��  ��  ��  ��  T m   ) *��
�� 
TEXT��  ��  Q m   + ,^^ �__  /O o      ���� 	0 _path  M `a` l  0 0��bc��  b . (# Reset AS delimiters to original values   c �dd P #   R e s e t   A S   d e l i m i t e r s   t o   o r i g i n a l   v a l u e sa efe r   0 5ghg o   0 1���� 0 astid ASTIDh n     iji 1   2 4��
�� 
txdlj 1   1 2��
�� 
ascrf k��k L   6 8ll o   6 7���� 	0 _path  ��  ' mnm l     ��������  ��  ��  n opo i    qrq I      ��s���� 0 _prepare_cmd  s t��t o      ���� 0 _cmd  ��  ��  r k     uu vwv l      ��xy��  x,& Ensure shell `_cmd` is working from the property directory.
	For testing purposes, it also sets the `AB_BRANCH` environmental variable.

	:param _cmd: Shell command to be run in `do shell script`
	:type _cmd: ``string``
	:returns: Shell command with `pwd` set properly
	:rtype: ``string``
		
	   y �zzL   E n s u r e   s h e l l   ` _ c m d `   i s   w o r k i n g   f r o m   t h e   p r o p e r t y   d i r e c t o r y . 
 	 F o r   t e s t i n g   p u r p o s e s ,   i t   a l s o   s e t s   t h e   ` A B _ B R A N C H `   e n v i r o n m e n t a l   v a r i a b l e . 
 
 	 : p a r a m   _ c m d :   S h e l l   c o m m a n d   t o   b e   r u n   i n   ` d o   s h e l l   s c r i p t ` 
 	 : t y p e   _ c m d :   ` ` s t r i n g ` ` 
 	 : r e t u r n s :   S h e l l   c o m m a n d   w i t h   ` p w d `   s e t   p r o p e r l y 
 	 : r t y p e :   ` ` s t r i n g ` ` 
 	 	 
 	w {|{ l     ��}~��  } 9 3# Ensure `pwd` is properly quoted for shell command   ~ � f #   E n s u r e   ` p w d `   i s   p r o p e r l y   q u o t e d   f o r   s h e l l   c o m m a n d| ��� r     	��� n     ��� 1    ��
�� 
strq� l    ������ n    ��� I    �������� 0 _pwd  ��  ��  �  f     ��  ��  � o      ���� 0 pwd  � ��� l  
 
������  � &  # Declare environmental variable   � ��� @ #   D e c l a r e   e n v i r o n m e n t a l   v a r i a b l e� ��� l  
 
������  � % #TODO: remove for final release   � ��� > # T O D O :   r e m o v e   f o r   f i n a l   r e l e a s e� ��� r   
 ��� m   
 �� ��� 0 e x p o r t   A B _ B R A N C H = d e v e l ;  � o      ���� 0 testing_var  � ��� l   ������  � 7 1# return shell script where `pwd` is properly set   � ��� b #   r e t u r n   s h e l l   s c r i p t   w h e r e   ` p w d `   i s   p r o p e r l y   s e t� ���� L    �� b    ��� b    ��� b    ��� b    ��� o    ���� 0 testing_var  � m    �� ���  c d  � o    ���� 0 pwd  � m    �� ���  ;   b a s h  � o    ���� 0 _cmd  ��  p ��� l     ��������  ��  ��  � ��� i    ��� I      ������� 0 _check_icon  � ���� o      ���� 	0 _icon  ��  ��  � k     �� ��� l      ������  � � � Check if `_icon` exists, and if not revert to system download icon.

	:returns: POSIX path to `_icon`
	:rtype: ``string`` (POSIX path)

	   � ���   C h e c k   i f   ` _ i c o n `   e x i s t s ,   a n d   i f   n o t   r e v e r t   t o   s y s t e m   d o w n l o a d   i c o n . 
 
 	 : r e t u r n s :   P O S I X   p a t h   t o   ` _ i c o n ` 
 	 : r t y p e :   ` ` s t r i n g ` `   ( P O S I X   p a t h ) 
 
 	� ���� Q     ���� k    �� ��� c    	��� 4    ���
�� 
psxf� o    ���� 	0 _icon  � m    ��
�� 
alis� ���� L   
 �� o   
 ���� 	0 _icon  ��  � R      ������
�� .ascrerr ****      � ****��  ��  � L    �� m    �� ��� � / S y s t e m / L i b r a r y / C o r e S e r v i c e s / C o r e T y p e s . b u n d l e / C o n t e n t s / R e s o u r c e s / S i d e b a r D o w n l o a d s F o l d e r . i c n s��  � ��� l     ��������  ��  ��  � ��� i    ��� I      ������� 0 
_check_dir  � ���� o      ���� 0 _folder  ��  ��  � k     �� ��� l      ������  � � � Check if `_folder` exists, and if not create it, including any sub-directories.

	:returns: POSIX path to `_folder`
	:rtype: ``string`` (POSIX path)

	   � ���0   C h e c k   i f   ` _ f o l d e r `   e x i s t s ,   a n d   i f   n o t   c r e a t e   i t ,   i n c l u d i n g   a n y   s u b - d i r e c t o r i e s . 
 
 	 : r e t u r n s :   P O S I X   p a t h   t o   ` _ f o l d e r ` 
 	 : r t y p e :   ` ` s t r i n g ` `   ( P O S I X   p a t h ) 
 
 	� ��� Z     ������� H     �� n    ��� I    ������� 0 _folder_exists  � ���� o    ���� 0 _folder  ��  ��  �  f     � I  
 �����
�� .sysoexecTEXT���     TEXT� b   
 ��� m   
 �� ���  m k d i r   - p  � l   ������ n    ��� 1    ��
�� 
strq� o    ���� 0 _folder  ��  ��  ��  ��  ��  � ���� L    �� o    ���� 0 _folder  ��  � ��� l     ��������  ��  ��  � ��� l     ��������  ��  ��  � ��� i    "��� I      ������� 0 _folder_exists  � ���� o      ���� 0 _folder  ��  ��  � k     �� ��� l      ������  � � � Return ``true`` if `_folder` exists, else ``false``

	:param _folder: Full path to directory
	:type _folder: ``string`` (POSIX path)
	:returns: ``Boolean``

	   � ���>   R e t u r n   ` ` t r u e ` `   i f   ` _ f o l d e r `   e x i s t s ,   e l s e   ` ` f a l s e ` ` 
 
 	 : p a r a m   _ f o l d e r :   F u l l   p a t h   t o   d i r e c t o r y 
 	 : t y p e   _ f o l d e r :   ` ` s t r i n g ` `   ( P O S I X   p a t h ) 
 	 : r e t u r n s :   ` ` B o o l e a n ` ` 
 
 	� ��� Z     ������� n    ��� I    �� ���� 0 _path_exists    �� o    ���� 0 _folder  ��  ��  �  f     � O   	  L     l   ���� =    n    	 m    ��
�� 
pcls	 l   
����
 4    ��
�� 
ditm o    ���� 0 _folder  ��  ��   m    ��
�� 
cfol��  ��   m   	 
�                                                                                  sevs  alis    �  Macintosh HD               ����H+  ҍKSystem Events.app                                              �U'�A��        ����  	                CoreServices    ���*      �A�9    ҍKҍHҍG  =Macintosh HD:System: Library: CoreServices: System Events.app   $  S y s t e m   E v e n t s . a p p    M a c i n t o s h   H D  -System/Library/CoreServices/System Events.app   / ��  ��  ��  � �� L     m    ��
�� boovfals��  �  l     �������  ��  �    i   # & I      �~�}�~ 0 _path_exists   �| o      �{�{ 	0 _path  �|  �}   k     Y  l      �z�z   � � Return ``true`` if `_path` exists, else ``false``

	:param _path: Any POSIX path (file or folder)
	:type _path: ``string`` (POSIX path)
	:returns: ``Boolean``

	    �D   R e t u r n   ` ` t r u e ` `   i f   ` _ p a t h `   e x i s t s ,   e l s e   ` ` f a l s e ` ` 
 
 	 : p a r a m   _ p a t h :   A n y   P O S I X   p a t h   ( f i l e   o r   f o l d e r ) 
 	 : t y p e   _ p a t h :   ` ` s t r i n g ` `   ( P O S I X   p a t h ) 
 	 : r e t u r n s :   ` ` B o o l e a n ` ` 
 
 	  Z     �y�x G     !"! =    #$# o     �w�w 	0 _path  $ m    �v
�v 
msng" n   %&% I    �u'�t�u 0 	_is_empty  ' (�s( o    �r�r 	0 _path  �s  �t  &  f      L    )) m    �q
�q boovfals�y  �x   *�p* Q    Y+,-+ k    O.. /0/ Z   )12�o�n1 =    343 n    565 m    �m
�m 
pcls6 o    �l�l 	0 _path  4 m    �k
�k 
alis2 L   # %77 m   # $�j
�j boovtrue�o  �n  0 8�i8 Z   * O9:;<9 E   * -=>= o   * +�h�h 	0 _path  > m   + ,?? �@@  :: k   0 8AA BCB 4   0 5�gD
�g 
alisD o   2 3�f�f 	0 _path  C E�eE L   6 8FF m   6 7�d
�d boovtrue�e  ; GHG E   ; >IJI o   ; <�c�c 	0 _path  J m   < =KK �LL  /H M�bM k   A JNN OPO c   A GQRQ 4   A E�aS
�a 
psxfS o   C D�`�` 	0 _path  R m   E F�_
�_ 
alisP T�^T L   H JUU m   H I�]
�] boovtrue�^  �b  < L   M OVV m   M N�\
�\ boovfals�i  , R      �[W�Z
�[ .ascrerr ****      � ****W o      �Y�Y 0 msg  �Z  - L   W YXX m   W X�X
�X boovfals�p   YZY l     �W�V�U�W  �V  �U  Z [\[ i   ' *]^] I      �T_�S�T 0 	_is_empty  _ `�R` o      �Q�Q 0 _obj  �R  �S  ^ k     (aa bcb l      �Pde�P  d � � Return ``true`` if `_obj ` is empty, else ``false``

	:param _obj: Any Applescript type
	:type _obj: (optional)
	:returns: ``Boolean``
		
	   e �ff   R e t u r n   ` ` t r u e ` `   i f   ` _ o b j   `   i s   e m p t y ,   e l s e   ` ` f a l s e ` ` 
 
 	 : p a r a m   _ o b j :   A n y   A p p l e s c r i p t   t y p e 
 	 : t y p e   _ o b j :   ( o p t i o n a l ) 
 	 : r e t u r n s :   ` ` B o o l e a n ` ` 
 	 	 
 	c ghg l     �Oij�O  i ! # Is `_obj ` a ``Boolean``?   j �kk 6 #   I s   ` _ o b j   `   a   ` ` B o o l e a n ` ` ?h lml Z    no�N�Mn E     pqp J     rr sts m     �L
�L boovtruet u�Ku m    �J
�J boovfals�K  q o    �I�I 0 _obj  o L   	 vv m   	 
�H
�H boovfals�N  �M  m wxw l   �Gyz�G  y ' !# Is `_obj ` a ``missing value``?   z �{{ B #   I s   ` _ o b j   `   a   ` ` m i s s i n g   v a l u e ` ` ?x |}| Z   ~�F�E~ =   ��� o    �D�D 0 _obj  � m    �C
�C 
msng L    �� m    �B
�B boovtrue�F  �E  } ��� l   �A���A  � " # Is `_obj ` a empty string?   � ��� 8 #   I s   ` _ o b j   `   a   e m p t y   s t r i n g ?� ��@� L    (�� =   '��� n    %��� 1   # %�?
�? 
leng� l   #��>�=� n   #��� I    #�<��;�< 	0 _trim  � ��:� o    �9�9 0 _obj  �:  �;  �  f    �>  �=  � m   % &�8�8  �@  \ ��� l     �7�6�5�7  �6  �5  � ��4� i   + .��� I      �3��2�3 	0 _trim  � ��1� o      �0�0 0 _str  �1  �2  � k     ��� ��� l      �/���/  � � � Remove white space from beginning and end of `_str`

	:param _str: A text string
	:type _str: ``string``
	:returns: trimmed string

	   � ���   R e m o v e   w h i t e   s p a c e   f r o m   b e g i n n i n g   a n d   e n d   o f   ` _ s t r ` 
 
 	 : p a r a m   _ s t r :   A   t e x t   s t r i n g 
 	 : t y p e   _ s t r :   ` ` s t r i n g ` ` 
 	 : r e t u r n s :   t r i m m e d   s t r i n g 
 
 	� ��� Z     ���.�-� G     ��� G     ��� >    ��� n     ��� m    �,
�, 
pcls� o     �+�+ 0 _str  � m    �*
�* 
ctxt� >   ��� n    ��� m   	 �)
�) 
pcls� o    	�(�( 0 _str  � m    �'
�' 
TEXT� =   ��� o    �&�& 0 _str  � m    �%
�% 
msng� L    �� o    �$�$ 0 _str  �.  �-  � ��� Z  ! -���#�"� =  ! $��� o   ! "�!�! 0 _str  � m   " #�� ���  � L   ' )�� o   ' (� �  0 _str  �#  �"  � ��� V   . W��� Q   6 R���� r   9 H��� c   9 F��� n   9 D��� 7  : D���
� 
cobj� m   > @�� � m   A C����� o   9 :�� 0 _str  � m   D E�
� 
ctxt� o      �� 0 _str  � R      ���
� .ascrerr ****      � ****� o      �� 0 msg  �  � L   P R�� m   P Q�� ���  � C  2 5��� o   2 3�� 0 _str  � m   3 4�� ���   � ��� V   X ���� Q   ` |���� r   c r��� c   c p��� n   c n��� 7  d n���
� 
cobj� m   h j�� � m   k m����� o   c d�� 0 _str  � m   n o�
� 
ctxt� o      �� 0 _str  � R      ���
� .ascrerr ****      � ****�  �  � L   z |�� m   z {�� ���  � D   \ _��� o   \ ]�� 0 _str  � m   ] ^�� ���   � ��� L   � ��� o   � ��
�
 0 _str  �  �4       �	� �������������	  � ��������� ��������� "0 bundler_version BUNDLER_VERSION� 0 load_bundler  � 0 
_bootstrap  � 0 _install_confirmation  � 0 _pwd  � 0 _prepare_cmd  � 0 _check_icon  � 0 
_check_dir  �  0 _folder_exists  �� 0 _path_exists  �� 0 	_is_empty  �� 	0 _trim  
�� .aevtoappnull  �   � ****� �� Q���������� 0 load_bundler  ��  ��  � ���� 0 
as_bundler  � ������ t�� ����� 0 bundler_dir BUNDLER_DIR�� 0 _folder_exists  �� 0 
_bootstrap  
�� .sysodelanull��� ��� nmbr
�� .sysoloadscpt        file�� ()�k+ e 
)j+ Y hO�j O��%E�O�j � �� ����������� 0 
_bootstrap  ��  ��  � �������������� 0 urls URLs�� 0 _zipfile  �� 0 _url  �� 0 _status  �� 0 _cmd  �� 0 
as_bundler  � "������ � � � ����� ������� � � ��� �
��������+0D��K��[�������� 0 _install_confirmation  ��  ��  �� 0 	cache_dir 	CACHE_DIR
�� 
strq
�� 
kocl
�� 
cobj
�� .corecnte****       ****
�� .sysoexecTEXT���     TEXT
�� 
errn�� �� 0 bundler_dir BUNDLER_DIR�� 0 
_check_dir  �� 0 _path_exists  
�� .sysodelanull��� ��� nmbr
�� 
psxf
�� 
alis
�� .coredeloobj        obj �� � 
)j+  W 	X  fO�b   %�%�b   %�%lvE�O��,�%E�O 1�[��l kh ��%�%�%�%j E�O�a   Y h[OY��O�a  )a a la Y hO)_ k+ Oa ��,%a %_ �,%E�O�j O_ a %E�O h)�k+ a j [OY��Oa  *a �/a  &j !UOh� ��g���������� 0 _install_confirmation  ��  ��  � �������������� 
0 _plist  �� 0 _cmd  �� 	0 _name  �� 	0 _icon  �� 	0 _text  �� 0 	_response  � ��{��������������������������������������� 0 _pwd  
�� .sysoexecTEXT���     TEXT�� 0 _check_icon  
�� 
btns
�� 
dflt
�� 
appr
�� 
disp
�� 
psxf�� 
�� .sysodlogaskr        TEXT
�� 
bhit
�� .GURLGURLnull��� ��� TEXT
�� 
errn�� �� �)j+  �%E�O�%�%E�O�j E�O)j+  �%E�O)�k+ E�O��%�%�%E�O�����mv�m��%a *a �/a  a ,E�O�a   eY hO�a    a  	a j UO)a a la Y hO�a   )a a la Y h� ��)���������� 0 _pwd  ��  ��  � ������ 0 astid ASTID�� 	0 _path  � 
����?������������^
�� 
ascr
�� 
txdl
�� 
cobj
�� .earsffdralis        afdr
�� 
psxp
�� 
citm����
�� 
TEXT�� 9��,�lvE[�k/E�Z[�l/��,FZO)j �,[�\[Zk\Z�2�&�%E�O���,FO�� ��r���� ���� 0 _prepare_cmd  �� ����   ���� 0 _cmd  ��    �������� 0 _cmd  �� 0 pwd  �� 0 testing_var   ��������� 0 _pwd  
�� 
strq�� )j+  �,E�O�E�O��%�%�%�%� ����������� 0 _check_icon  �� ����   ���� 	0 _icon  ��   ���� 	0 _icon   ���������
�� 
psxf
�� 
alis��  ��  ��  *�/�&O�W 	X  �� ����������� 0 
_check_dir  �� ����   ���� 0 _folder  ��   ���� 0 _folder   ��������� 0 _folder_exists  
�� 
strq
�� .sysoexecTEXT���     TEXT�� )�k+   ��,%j Y hO�� �������	
���� 0 _folder_exists  �� ����   ���� 0 _folder  ��  	 ���� 0 _folder  
 ���������� 0 _path_exists  
�� 
ditm
�� 
pcls
�� 
cfol�� )�k+   � *�/�,� UY hOf� ���������� 0 _path_exists  �� ����   �� 	0 _path  ��   �~�}�~ 	0 _path  �} 0 msg   
�|�{�z�y�x?K�w�v�u
�| 
msng�{ 0 	_is_empty  
�z 
bool
�y 
pcls
�x 
alis
�w 
psxf�v 0 msg  �u  �� Z�� 
 
)�k+ �& fY hO 9��,�  eY hO�� *�/EOeY �� *�/�&OeY fW 	X  	f� �t^�s�r�q�t 0 	_is_empty  �s �p�p   �o�o 0 _obj  �r   �n�n 0 _obj   �m�l�k
�m 
msng�l 	0 _trim  
�k 
leng�q )eflv� fY hO��  eY hO)�k+ �,j � �j��i�h�g�j 	0 _trim  �i �f�f   �e�e 0 _str  �h   �d�c�d 0 _str  �c 0 msg   �b�a�`�_�^���]�\�[���Z�Y�
�b 
pcls
�a 
ctxt
�` 
TEXT
�_ 
bool
�^ 
msng
�] 
cobj�\ 0 msg  �[  �Z���Y  �g ���,�
 	��,��&
 �� �& �Y hO��  �Y hO (h�� �[�\[Zl\Zi2�&E�W 	X  	�[OY��O (h�� �[�\[Zk\Z�2�&E�W 	X  	�[OY��O�� �X�W�V�U
�X .aevtoappnull  �   � **** k     '    1�T�T  �W  �V     	�S�R�Q�P�O '�N A�M
�S afdrcusr
�R 
rtyp
�Q 
ctxt
�P .earsffdralis        afdr
�O 
psxp�N 0 bundler_dir BUNDLER_DIR�M 0 	cache_dir 	CACHE_DIR�U (���l �,�%b   %E�O���l �,�%b   %E�ascr  ��ޭ