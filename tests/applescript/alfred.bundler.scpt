FasdUAS 1.101.10   ��   ��    k             l     ��  ��    &  # Current Alfred-Bundler version     � 	 	 @ #   C u r r e n t   A l f r e d - B u n d l e r   v e r s i o n   
  
 j     �� �� "0 bundler_version BUNDLER_VERSION  m        �   
 d e v e l      l     ��  ��    / )# Path to Alfred-Bundler's root directory     �   R #   P a t h   t o   A l f r e d - B u n d l e r ' s   r o o t   d i r e c t o r y      i        I      �������� 0 get_bundler_dir  ��  ��    L        b         b         l    	 ����  n     	    1    	��
�� 
psxp  l      ����   I    �� ! "
�� .earsffdralis        afdr ! m     ��
�� afdrcusr " �� #��
�� 
rtyp # m    ��
�� 
ctxt��  ��  ��  ��  ��    m   	 
 $ $ � % % � L i b r a r y / A p p l i c a t i o n   S u p p o r t / A l f r e d   2 / W o r k f l o w   D a t a / a l f r e d . b u n d l e r -  o    ���� "0 bundler_version BUNDLER_VERSION   & ' & l     �� ( )��   ( 0 *# Path to Alfred-Bundler's cache directory    ) � * * T #   P a t h   t o   A l f r e d - B u n d l e r ' s   c a c h e   d i r e c t o r y '  + , + i    
 - . - I      �������� 0 get_cache_dir  ��  ��   . L      / / b      0 1 0 b      2 3 2 l    	 4���� 4 n     	 5 6 5 1    	��
�� 
psxp 6 l     7���� 7 I    �� 8 9
�� .earsffdralis        afdr 8 m     ��
�� afdrcusr 9 �� :��
�� 
rtyp : m    ��
�� 
ctxt��  ��  ��  ��  ��   3 m   	 
 ; ; � < < � L i b r a r y / C a c h e s / c o m . r u n n i n g w i t h c r a y o n s . A l f r e d - 2 / W o r k f l o w   D a t a / a l f r e d . b u n d l e r - 1 o    ���� "0 bundler_version BUNDLER_VERSION ,  = > = l     ��������  ��  ��   >  ? @ ? l     ��������  ��  ��   @  A B A l      �� C D��   C   MAIN API FUNCTION     D � E E &   M A I N   A P I   F U N C T I O N   B  F G F l     ��������  ��  ��   G  H I H i     J K J I      �������� 0 load_bundler  ��  ��   K k     / L L  M N M l      �� O P��   O � � Load `AlfredBundler.scpt` from the Alfred-Bundler directory as a script object. 
	If the Alfred-Bundler directory does not exist, install it (using `_bootstrap()`).

	:returns: the script object of `AlfredBundler.scpt`
	:rtype: ``script object``

	    P � Q Q�   L o a d   ` A l f r e d B u n d l e r . s c p t `   f r o m   t h e   A l f r e d - B u n d l e r   d i r e c t o r y   a s   a   s c r i p t   o b j e c t .   
 	 I f   t h e   A l f r e d - B u n d l e r   d i r e c t o r y   d o e s   n o t   e x i s t ,   i n s t a l l   i t   ( u s i n g   ` _ b o o t s t r a p ( ) ` ) . 
 
 	 : r e t u r n s :   t h e   s c r i p t   o b j e c t   o f   ` A l f r e d B u n d l e r . s c p t ` 
 	 : r t y p e :   ` ` s c r i p t   o b j e c t ` ` 
 
 	 N  R S R r      T U T n     V W V I    �������� 0 get_bundler_dir  ��  ��   W  f      U o      ���� 0 bundler_dir BUNDLER_DIR S  X Y X l   �� Z [��   Z , &# Check if Alfred-Bundler is installed    [ � \ \ L #   C h e c k   i f   A l f r e d - B u n d l e r   i s   i n s t a l l e d Y  ] ^ ] Z     _ `���� _ >    a b a l    c���� c n    d e d I   	 �� f���� 0 _folder_exists   f  g�� g o   	 
���� 0 bundler_dir BUNDLER_DIR��  ��   e  f    	��  ��   b m    ��
�� boovtrue ` k     h h  i j i l   �� k l��   k  # install it if not    l � m m & #   i n s t a l l   i t   i f   n o t j  n�� n n    o p o I    �������� 0 
_bootstrap  ��  ��   p  f    ��  ��  ��   ^  q r q I   "�� s��
�� .sysodelanull��� ��� nmbr s m     t t ?���������   r  u v u l  # #�� w x��   w ? 9# Path to `AlfredBundler.scpt` in Alfed-Bundler directory    x � y y r #   P a t h   t o   ` A l f r e d B u n d l e r . s c p t `   i n   A l f e d - B u n d l e r   d i r e c t o r y v  z { z r   # ( | } | l  # & ~���� ~ b   # &  �  o   # $���� 0 bundler_dir BUNDLER_DIR � m   $ % � � � � � 6 / b u n d l e r / A l f r e d B u n d l e r . s c p t��  ��   } o      ���� 0 
as_bundler   {  � � � l  ) )�� � ���   �  # Return script object    � � � � , #   R e t u r n   s c r i p t   o b j e c t �  ��� � L   ) / � � I  ) .�� ���
�� .sysoloadscpt        file � o   ) *���� 0 
as_bundler  ��  ��   I  � � � l     ��������  ��  ��   �  � � � l      �� � ���   �   AUTO-DOWNLOAD BUNDLER     � � � � .   A U T O - D O W N L O A D   B U N D L E R   �  � � � l     ��������  ��  ��   �  � � � i     � � � I      �������� 0 
_bootstrap  ��  ��   � k     � � �  � � � l      �� � ���   � ` Z Check if bundler bash bundlet is installed and install it if not.

	:returns: ``None``

	    � � � � �   C h e c k   i f   b u n d l e r   b a s h   b u n d l e t   i s   i n s t a l l e d   a n d   i n s t a l l   i t   i f   n o t . 
 
 	 : r e t u r n s :   ` ` N o n e ` ` 
 
 	 �  � � � l     �� � ���   � " # Ask to install the Bundler    � � � � 8 #   A s k   t o   i n s t a l l   t h e   B u n d l e r �  � � � r      � � � n     � � � I    �������� 0 get_bundler_dir  ��  ��   �  f      � o      ���� 0 bundler_dir BUNDLER_DIR �  � � � r     � � � n    � � � I   	 �������� 0 get_cache_dir  ��  ��   �  f    	 � o      ���� 0 	cache_dir 	CACHE_DIR �  � � � Q    " � � � � n    � � � I    �������� 0 _install_confirmation  ��  ��   �  f     � R      ������
�� .ascrerr ****      � ****��  ��   � k     " � �  � � � l     �� � ���   � 7 1# Cannot continue to install the bundler, so stop    � � � � b #   C a n n o t   c o n t i n u e   t o   i n s t a l l   t h e   b u n d l e r ,   s o   s t o p �  ��� � L     " � � m     !��
�� boovfals��   �  � � � l  # #�� � ���   �  # Download the bundler    � � � � , #   D o w n l o a d   t h e   b u n d l e r �  � � � r   # 9 � � � J   # 7 � �  � � � b   # , � � � b   # * � � � m   # $ � � � � � h h t t p s : / / g i t h u b . c o m / s h a w n r i c e / a l f r e d - b u n d l e r / a r c h i v e / � o   $ )���� "0 bundler_version BUNDLER_VERSION � m   * + � � � � �  . z i p �  ��� � b   , 5 � � � b   , 3 � � � m   , - � � � � � f h t t p s : / / b i t b u c k e t . o r g / s h a w n r i c e / a l f r e d - b u n d l e r / g e t / � o   - 2���� "0 bundler_version BUNDLER_VERSION � m   3 4 � � � � �  . z i p��   � o      ���� 0 urls URLs �  � � � l  : :�� � ���   � @ :# Save Alfred-Bundler zipfile to this location temporarily    � � � � t #   S a v e   A l f r e d - B u n d l e r   z i p f i l e   t o   t h i s   l o c a t i o n   t e m p o r a r i l y �  � � � r   : A � � � b   : ? � � � l  : = ����� � n   : = � � � 1   ; =��
�� 
strq � o   : ;���� 0 	cache_dir 	CACHE_DIR��  ��   � m   = > � � � � � , / i n s t a l l e r / b u n d l e r . z i p � o      ���� 0 _zipfile   �  � � � X   B v ��� � � k   R q � �  � � � r   R c � � � l  R a ����� � I  R a�� ���
�� .sysoexecTEXT���     TEXT � b   R ] � � � b   R Y � � � b   R W � � � b   R U � � � m   R S � � � � � Z c u r l   - f s S L   - - c r e a t e - d i r s   - - c o n n e c t - t i m e o u t   5   � o   S T���� 0 _url   � m   U V   �    - o   � o   W X���� 0 _zipfile   � m   Y \ �    & &   e c h o   $ ?��  ��  ��   � o      ���� 0 _status   � �� Z  d q��� =  d i o   d e�~�~ 0 _status   m   e h		 �

  0  S   l m��  �  ��  �� 0 _url   � o   E F�}�} 0 urls URLs �  l  w w�|�|   # # Could not download the file    � : #   C o u l d   n o t   d o w n l o a d   t h e   f i l e  Z  w ��{�z >  w | o   w x�y�y 0 _status   m   x { �  0 R    ��x
�x .ascrerr ****      � **** m   � � � N C o u l d   n o t   d o w n l o a d   b u n d l e r   i n s t a l l   f i l e �w�v
�w 
errn m   � ��u�u �v  �{  �z    l  � ��t �t   L F# Ensure directory tree already exists for bundler to be moved into it     �!! � #   E n s u r e   d i r e c t o r y   t r e e   a l r e a d y   e x i s t s   f o r   b u n d l e r   t o   b e   m o v e d   i n t o   i t "#" n  � �$%$ I   � ��s&�r�s 0 
_check_dir  & '�q' o   � ��p�p 0 bundler_dir BUNDLER_DIR�q  �r  %  f   � �# ()( l  � ��o*+�o  * ; 5# Unzip the bundler and move it to its data directory   + �,, j #   U n z i p   t h e   b u n d l e r   a n d   m o v e   i t   t o   i t s   d a t a   d i r e c t o r y) -.- r   � �/0/ b   � �121 b   � �343 b   � �565 m   � �77 �88  c d  6 l  � �9�n�m9 n   � �:;: 1   � ��l
�l 
strq; o   � ��k�k 0 	cache_dir 	CACHE_DIR�n  �m  4 m   � �<< �== l ;   c d   i n s t a l l e r ;   u n z i p   - q o   b u n d l e r . z i p ;   m v   . / * / b u n d l e r  2 l  � �>�j�i> n   � �?@? 1   � ��h
�h 
strq@ o   � ��g�g 0 bundler_dir BUNDLER_DIR�j  �i  0 o      �f�f 0 _cmd  . ABA I  � ��eC�d
�e .sysoexecTEXT���     TEXTC o   � ��c�c 0 _cmd  �d  B DED l  � ��bFG�b  F Q K# Wait until bundler is fully unzipped and written to disk before finishing   G �HH � #   W a i t   u n t i l   b u n d l e r   i s   f u l l y   u n z i p p e d   a n d   w r i t t e n   t o   d i s k   b e f o r e   f i n i s h i n gE IJI r   � �KLK l  � �M�a�`M b   � �NON o   � ��_�_ 0 bundler_dir BUNDLER_DIRO m   � �PP �QQ 6 / b u n d l e r / A l f r e d B u n d l e r . s c p t�a  �`  L o      �^�^ 0 
as_bundler  J RSR V   � �TUT I  � ��]V�\
�] .sysodelanull��� ��� nmbrV m   � �WW ?ə������\  U H   � �XX l  � �Y�[�ZY n  � �Z[Z I   � ��Y\�X�Y 0 _path_exists  \ ]�W] o   � ��V�V 0 
as_bundler  �W  �X  [  f   � ��[  �Z  S ^_^ O  � �`a` I  � ��Ub�T
�U .coredeloobj        obj b l  � �c�S�Rc c   � �ded 4   � ��Qf
�Q 
psxff o   � ��P�P 0 	cache_dir 	CACHE_DIRe m   � ��O
�O 
alis�S  �R  �T  a m   � �gg�                                                                                  MACS  alis    t  Macintosh HD               ����H+  ҍK
Finder.app                                                     ԲY�`�        ����  	                CoreServices    ���*      �`D    ҍKҍHҍG  6Macintosh HD:System: Library: CoreServices: Finder.app   
 F i n d e r . a p p    M a c i n t o s h   H D  &System/Library/CoreServices/Finder.app  / ��  _ h�Nh L   � ��M�M  �N   � iji l     �L�K�J�L  �K  �J  j klk l     �Imn�I  m ; 5# Function to get confirmation to install the bundler   n �oo j #   F u n c t i o n   t o   g e t   c o n f i r m a t i o n   t o   i n s t a l l   t h e   b u n d l e rl pqp i    rsr I      �H�G�F�H 0 _install_confirmation  �G  �F  s k     �tt uvu l      �Ewx�E  w � � Ask user for permission to install Alfred-Bundler. 
	Allow user to go to website for more information, or even to cancel download.

	:returns: ``True`` or raises Error

	   x �yyV   A s k   u s e r   f o r   p e r m i s s i o n   t o   i n s t a l l   A l f r e d - B u n d l e r .   
 	 A l l o w   u s e r   t o   g o   t o   w e b s i t e   f o r   m o r e   i n f o r m a t i o n ,   o r   e v e n   t o   c a n c e l   d o w n l o a d . 
 
 	 : r e t u r n s :   ` ` T r u e ` `   o r   r a i s e s   E r r o r 
 
 	v z{z l     �D|}�D  | 0 *# Get path to workflow's `info.plist` file   } �~~ T #   G e t   p a t h   t o   w o r k f l o w ' s   ` i n f o . p l i s t `   f i l e{ � r     	��� b     ��� n    ��� I    �C�B�A�C 0 _pwd  �B  �A  �  f     � m    �� ���  i n f o . p l i s t� o      �@�@ 
0 _plist  � ��� l  
 
�?���?  � 5 /# Get name of workflow's from `info.plist` file   � ��� ^ #   G e t   n a m e   o f   w o r k f l o w ' s   f r o m   ` i n f o . p l i s t `   f i l e� ��� r   
 ��� b   
 ��� b   
 ��� m   
 �� ��� T / u s r / l i b e x e c / P l i s t B u d d y   - c   ' P r i n t   : n a m e '   '� o    �>�> 
0 _plist  � m    �� ���  '� o      �=�= 0 _cmd  � ��� r    ��� I   �<��;
�< .sysoexecTEXT���     TEXT� o    �:�: 0 _cmd  �;  � o      �9�9 	0 _name  � ��� l   �8���8  � 6 0# Get workflow's icon, or default to system icon   � ��� ` #   G e t   w o r k f l o w ' s   i c o n ,   o r   d e f a u l t   t o   s y s t e m   i c o n� ��� r    #��� b    !��� n   ��� I    �7�6�5�7 0 _pwd  �6  �5  �  f    � m     �� ���  i c o n . p n g� o      �4�4 	0 _icon  � ��� r   $ ,��� n  $ *��� I   % *�3��2�3 0 _check_icon  � ��1� o   % &�0�0 	0 _icon  �1  �2  �  f   $ %� o      �/�/ 	0 _icon  � ��� l  - -�.���.  � / )# Prepare explanation text for dialog box   � ��� R #   P r e p a r e   e x p l a n a t i o n   t e x t   f o r   d i a l o g   b o x� ��� r   - 6��� b   - 4��� b   - 2��� b   - 0��� o   - .�-�- 	0 _name  � m   . /�� ���   n e e d s   t o   i n s t a l l   a d d i t i o n a l   c o m p o n e n t s ,   w h i c h   w i l l   b e   p l a c e d   i n   t h e   A l f r e d   s t o r a g e   d i r e c t o r y   a n d   w i l l   n o t   i n t e r f e r e   w i t h   y o u r   s y s t e m . 
 
 Y o u   m a y   b e   a s k e d   t o   a l l o w   s o m e   c o m p o n e n t s   t o   r u n ,   d e p e n d i n g   o n   y o u r   s e c u r i t y   s e t t i n g s . 
 
 Y o u   c a n   d e c l i n e   t h i s   i n s t a l l a t i o n ,   b u t  � o   0 1�,�, 	0 _name  � m   2 3�� ��� �   m a y   n o t   w o r k   w i t h o u t   t h e m .   T h e r e   w i l l   b e   a   s l i g h t   d e l a y   a f t e r   a c c e p t i n g .� o      �+�+ 	0 _text  � ��� l  7 7�*�)�(�*  �)  �(  � ��� r   7 Y��� n   7 W��� 1   S W�'
�' 
bhit� l  7 S��&�%� I  7 S�$��
�$ .sysodlogaskr        TEXT� o   7 8�#�# 	0 _text  � �"��
�" 
btns� J   9 >�� ��� m   9 :�� ���  M o r e   I n f o� ��� m   : ;�� ���  C a n c e l� ��!� m   ; <�� ���  P r o c e e d�!  � � ��
�  
dflt� m   ? @�� � ���
� 
appr� b   A D��� m   A B�� ���  S e t u p  � o   B C�� 	0 _name  � ���
� 
disp� 4   G M��
� 
psxf� o   K L�� 	0 _icon  �  �&  �%  � o      �� 0 	_response  � ��� l  Z Z����  � 0 *# If permission granted, continue download   � ��� T #   I f   p e r m i s s i o n   g r a n t e d ,   c o n t i n u e   d o w n l o a d� ��� Z  Z h����� =  Z _��� o   Z [�� 0 	_response  � m   [ ^�� ���  P r o c e e d� L   b d�� m   b c�
� boovtrue�  �  � ��� l  i i����  � 6 0# If more info requested, open webpage and error   � ��� ` #   I f   m o r e   i n f o   r e q u e s t e d ,   o p e n   w e b p a g e   a n d   e r r o r� � � Z   i ��� =  i n o   i j�� 0 	_response   m   j m �  M o r e   I n f o k   q � 	 O   q 

 I  w ~��
� .GURLGURLnull��� ��� TEXT m   w z � � h t t p s : / / g i t h u b . c o m / s h a w n r i c e / a l f r e d - b u n d l e r / w i k i / W h a t - i s - t h e - A l f r e d - B u n d l e r�   m   q t�                                                                                  sevs  alis    �  Macintosh HD               ����H+  ҍKSystem Events.app                                              �U'�A��        ����  	                CoreServices    ���*      �A�9    ҍKҍHҍG  =Macintosh HD:System: Library: CoreServices: System Events.app   $  S y s t e m   E v e n t s . a p p    M a c i n t o s h   H D  -System/Library/CoreServices/System Events.app   / ��  	 � R   � ��
� .ascrerr ****      � **** m   � � � F U s e r   l o o k e d   s o u g h t   m o r e   i n f o r m a t i o n �
�	
�
 
errn m   � ��� �	  �  �  �     l  � ���   , &# If permission denied, stop and error    � L #   I f   p e r m i s s i o n   d e n i e d ,   s t o p   a n d   e r r o r � Z  � ��� =  � � o   � ��� 0 	_response   m   � �   �!!  C a n c e l R   � ��"#
� .ascrerr ****      � ****" m   � �$$ �%% D U s e r   c a n c e l e d   b u n d l e r   i n s t a l l a t i o n# �&� 
� 
errn& m   � ����� �   �  �  �  q '(' l     ��������  ��  ��  ( )*) l     ��������  ��  ��  * +,+ l      ��-.��  -   HELPER HANDLERS    . �// "   H E L P E R   H A N D L E R S  , 010 l     ��������  ��  ��  1 232 i    454 I      �������� 0 _pwd  ��  ��  5 k     866 787 l      ��9:��  9 � � Get path to "present working directory", i.e. the workflow's root directory.
	
	:returns: Path to this script's parent directory
	:rtype: ``string`` (POSIX path)

	   : �;;J   G e t   p a t h   t o   " p r e s e n t   w o r k i n g   d i r e c t o r y " ,   i . e .   t h e   w o r k f l o w ' s   r o o t   d i r e c t o r y . 
 	 
 	 : r e t u r n s :   P a t h   t o   t h i s   s c r i p t ' s   p a r e n t   d i r e c t o r y 
 	 : r t y p e :   ` ` s t r i n g ` `   ( P O S I X   p a t h ) 
 
 	8 <=< l     ��>?��  > = 7# Save default AS delimiters, and set delimiters to "/"   ? �@@ n #   S a v e   d e f a u l t   A S   d e l i m i t e r s ,   a n d   s e t   d e l i m i t e r s   t o   " / "= ABA r     CDC J     EE FGF n    HIH 1    ��
�� 
txdlI 1     ��
�� 
ascrG J��J m    KK �LL  /��  D J      MM NON o      ���� 0 astid ASTIDO P��P n     QRQ 1    ��
�� 
txdlR 1    ��
�� 
ascr��  B STS l   ��UV��  U , &# Get POSIX path of script's directory   V �WW L #   G e t   P O S I X   p a t h   o f   s c r i p t ' s   d i r e c t o r yT XYX r    /Z[Z b    -\]\ l   +^����^ c    +_`_ n    )aba 7   )��cd
�� 
citmc m   # %���� d m   & (������b l   e����e n    fgf 1    ��
�� 
psxpg l   h����h I   ��i��
�� .earsffdralis        afdri  f    ��  ��  ��  ��  ��  ` m   ) *��
�� 
TEXT��  ��  ] m   + ,jj �kk  /[ o      ���� 	0 _path  Y lml l  0 0��no��  n . (# Reset AS delimiters to original values   o �pp P #   R e s e t   A S   d e l i m i t e r s   t o   o r i g i n a l   v a l u e sm qrq r   0 5sts o   0 1���� 0 astid ASTIDt n     uvu 1   2 4��
�� 
txdlv 1   1 2��
�� 
ascrr w��w L   6 8xx o   6 7���� 	0 _path  ��  3 yzy l     ��������  ��  ��  z {|{ i    }~} I      ������ 0 _prepare_cmd   ���� o      ���� 0 _cmd  ��  ��  ~ k     �� ��� l      ������  �,& Ensure shell `_cmd` is working from the property directory.
	For testing purposes, it also sets the `AB_BRANCH` environmental variable.

	:param _cmd: Shell command to be run in `do shell script`
	:type _cmd: ``string``
	:returns: Shell command with `pwd` set properly
	:rtype: ``string``
		
	   � ���L   E n s u r e   s h e l l   ` _ c m d `   i s   w o r k i n g   f r o m   t h e   p r o p e r t y   d i r e c t o r y . 
 	 F o r   t e s t i n g   p u r p o s e s ,   i t   a l s o   s e t s   t h e   ` A B _ B R A N C H `   e n v i r o n m e n t a l   v a r i a b l e . 
 
 	 : p a r a m   _ c m d :   S h e l l   c o m m a n d   t o   b e   r u n   i n   ` d o   s h e l l   s c r i p t ` 
 	 : t y p e   _ c m d :   ` ` s t r i n g ` ` 
 	 : r e t u r n s :   S h e l l   c o m m a n d   w i t h   ` p w d `   s e t   p r o p e r l y 
 	 : r t y p e :   ` ` s t r i n g ` ` 
 	 	 
 	� ��� l     ������  � 9 3# Ensure `pwd` is properly quoted for shell command   � ��� f #   E n s u r e   ` p w d `   i s   p r o p e r l y   q u o t e d   f o r   s h e l l   c o m m a n d� ��� r     	��� n     ��� 1    ��
�� 
strq� l    ������ n    ��� I    �������� 0 _pwd  ��  ��  �  f     ��  ��  � o      ���� 0 pwd  � ��� l  
 
������  � &  # Declare environmental variable   � ��� @ #   D e c l a r e   e n v i r o n m e n t a l   v a r i a b l e� ��� l  
 
������  � % #TODO: remove for final release   � ��� > # T O D O :   r e m o v e   f o r   f i n a l   r e l e a s e� ��� r   
 ��� m   
 �� ��� 0 e x p o r t   A B _ B R A N C H = d e v e l ;  � o      ���� 0 testing_var  � ��� l   ������  � 7 1# return shell script where `pwd` is properly set   � ��� b #   r e t u r n   s h e l l   s c r i p t   w h e r e   ` p w d `   i s   p r o p e r l y   s e t� ���� L    �� b    ��� b    ��� b    ��� b    ��� o    ���� 0 testing_var  � m    �� ���  c d  � o    ���� 0 pwd  � m    �� ���  ;   b a s h  � o    ���� 0 _cmd  ��  | ��� l     ��������  ��  ��  � ��� i    "��� I      ������� 0 _check_icon  � ���� o      ���� 	0 _icon  ��  ��  � k     �� ��� l      ������  � � � Check if `_icon` exists, and if not revert to system download icon.

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
�� .ascrerr ****      � ****��  ��  � L    �� m    �� ��� � / S y s t e m / L i b r a r y / C o r e S e r v i c e s / C o r e T y p e s . b u n d l e / C o n t e n t s / R e s o u r c e s / S i d e b a r D o w n l o a d s F o l d e r . i c n s��  � ��� l     ��������  ��  ��  � ��� i   # &��� I      ������� 0 
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
strq� o    ���� 0 _folder  ��  ��  ��  ��  ��  � ���� L    �� o    ���� 0 _folder  ��  � ��� l     ��������  ��  ��  � ��� l     ��������  ��  ��  � ��� i   ' *��� I      ������� 0 _folder_exists  � ���� o      ���� 0 _folder  ��  ��  � k         l      ����   � � Return ``true`` if `_folder` exists, else ``false``

	:param _folder: Full path to directory
	:type _folder: ``string`` (POSIX path)
	:returns: ``Boolean``

	    �>   R e t u r n   ` ` t r u e ` `   i f   ` _ f o l d e r `   e x i s t s ,   e l s e   ` ` f a l s e ` ` 
 
 	 : p a r a m   _ f o l d e r :   F u l l   p a t h   t o   d i r e c t o r y 
 	 : t y p e   _ f o l d e r :   ` ` s t r i n g ` `   ( P O S I X   p a t h ) 
 	 : r e t u r n s :   ` ` B o o l e a n ` ` 
 
 	  Z     	���� n    

 I    ������ 0 _path_exists   �� o    ���� 0 _folder  ��  ��    f     	 O   	  L     l   ���� =    n     m    ��
�� 
pcls l   ��� 4    �~
�~ 
ditm o    �}�} 0 _folder  ��  �   m    �|
�| 
cfol��  ��   m   	 
�                                                                                  sevs  alis    �  Macintosh HD               ����H+  ҍKSystem Events.app                                              �U'�A��        ����  	                CoreServices    ���*      �A�9    ҍKҍHҍG  =Macintosh HD:System: Library: CoreServices: System Events.app   $  S y s t e m   E v e n t s . a p p    M a c i n t o s h   H D  -System/Library/CoreServices/System Events.app   / ��  ��  ��   �{ L     m    �z
�z boovfals�{  �  l     �y�x�w�y  �x  �w    i   + .  I      �v!�u�v 0 _path_exists  ! "�t" o      �s�s 	0 _path  �t  �u    k     Y## $%$ l      �r&'�r  & � � Return ``true`` if `_path` exists, else ``false``

	:param _path: Any POSIX path (file or folder)
	:type _path: ``string`` (POSIX path)
	:returns: ``Boolean``

	   ' �((D   R e t u r n   ` ` t r u e ` `   i f   ` _ p a t h `   e x i s t s ,   e l s e   ` ` f a l s e ` ` 
 
 	 : p a r a m   _ p a t h :   A n y   P O S I X   p a t h   ( f i l e   o r   f o l d e r ) 
 	 : t y p e   _ p a t h :   ` ` s t r i n g ` `   ( P O S I X   p a t h ) 
 	 : r e t u r n s :   ` ` B o o l e a n ` ` 
 
 	% )*) Z    +,�q�p+ G     -.- =    /0/ o     �o�o 	0 _path  0 m    �n
�n 
msng. n   121 I    �m3�l�m 0 	_is_empty  3 4�k4 o    �j�j 	0 _path  �k  �l  2  f    , L    55 m    �i
�i boovfals�q  �p  * 6�h6 Q    Y7897 k    O:: ;<; Z   )=>�g�f= =    ?@? n    ABA m    �e
�e 
pclsB o    �d�d 	0 _path  @ m    �c
�c 
alis> L   # %CC m   # $�b
�b boovtrue�g  �f  < D�aD Z   * OEFGHE E   * -IJI o   * +�`�` 	0 _path  J m   + ,KK �LL  :F k   0 8MM NON 4   0 5�_P
�_ 
alisP o   2 3�^�^ 	0 _path  O Q�]Q L   6 8RR m   6 7�\
�\ boovtrue�]  G STS E   ; >UVU o   ; <�[�[ 	0 _path  V m   < =WW �XX  /T Y�ZY k   A JZZ [\[ c   A G]^] 4   A E�Y_
�Y 
psxf_ o   C D�X�X 	0 _path  ^ m   E F�W
�W 
alis\ `�V` L   H Jaa m   H I�U
�U boovtrue�V  �Z  H L   M Obb m   M N�T
�T boovfals�a  8 R      �Sc�R
�S .ascrerr ****      � ****c o      �Q�Q 0 msg  �R  9 L   W Ydd m   W X�P
�P boovfals�h   efe l     �O�N�M�O  �N  �M  f ghg i   / 2iji I      �Lk�K�L 0 	_is_empty  k l�Jl o      �I�I 0 _obj  �J  �K  j k     (mm non l      �Hpq�H  p � � Return ``true`` if `_obj ` is empty, else ``false``

	:param _obj: Any Applescript type
	:type _obj: (optional)
	:returns: ``Boolean``
		
	   q �rr   R e t u r n   ` ` t r u e ` `   i f   ` _ o b j   `   i s   e m p t y ,   e l s e   ` ` f a l s e ` ` 
 
 	 : p a r a m   _ o b j :   A n y   A p p l e s c r i p t   t y p e 
 	 : t y p e   _ o b j :   ( o p t i o n a l ) 
 	 : r e t u r n s :   ` ` B o o l e a n ` ` 
 	 	 
 	o sts l     �Guv�G  u ! # Is `_obj ` a ``Boolean``?   v �ww 6 #   I s   ` _ o b j   `   a   ` ` B o o l e a n ` ` ?t xyx Z    z{�F�Ez E     |}| J     ~~ � m     �D
�D boovtrue� ��C� m    �B
�B boovfals�C  } o    �A�A 0 _obj  { L   	 �� m   	 
�@
�@ boovfals�F  �E  y ��� l   �?���?  � ' !# Is `_obj ` a ``missing value``?   � ��� B #   I s   ` _ o b j   `   a   ` ` m i s s i n g   v a l u e ` ` ?� ��� Z   ���>�=� =   ��� o    �<�< 0 _obj  � m    �;
�; 
msng� L    �� m    �:
�: boovtrue�>  �=  � ��� l   �9���9  � " # Is `_obj ` a empty string?   � ��� 8 #   I s   ` _ o b j   `   a   e m p t y   s t r i n g ?� ��8� L    (�� =   '��� n    %��� 1   # %�7
�7 
leng� l   #��6�5� n   #��� I    #�4��3�4 	0 _trim  � ��2� o    �1�1 0 _obj  �2  �3  �  f    �6  �5  � m   % &�0�0  �8  h ��� l     �/�.�-�/  �.  �-  � ��,� i   3 6��� I      �+��*�+ 	0 _trim  � ��)� o      �(�( 0 _str  �)  �*  � k     ��� ��� l      �'���'  � � � Remove white space from beginning and end of `_str`

	:param _str: A text string
	:type _str: ``string``
	:returns: trimmed string

	   � ���   R e m o v e   w h i t e   s p a c e   f r o m   b e g i n n i n g   a n d   e n d   o f   ` _ s t r ` 
 
 	 : p a r a m   _ s t r :   A   t e x t   s t r i n g 
 	 : t y p e   _ s t r :   ` ` s t r i n g ` ` 
 	 : r e t u r n s :   t r i m m e d   s t r i n g 
 
 	� ��� Z     ���&�%� G     ��� G     ��� >    ��� n     ��� m    �$
�$ 
pcls� o     �#�# 0 _str  � m    �"
�" 
ctxt� >   ��� n    ��� m   	 �!
�! 
pcls� o    	� �  0 _str  � m    �
� 
TEXT� =   ��� o    �� 0 _str  � m    �
� 
msng� L    �� o    �� 0 _str  �&  �%  � ��� Z  ! -����� =  ! $��� o   ! "�� 0 _str  � m   " #�� ���  � L   ' )�� o   ' (�� 0 _str  �  �  � ��� V   . W��� Q   6 R���� r   9 H��� c   9 F��� n   9 D��� 7  : D���
� 
cobj� m   > @�� � m   A C����� o   9 :�� 0 _str  � m   D E�
� 
ctxt� o      �� 0 _str  � R      ���
� .ascrerr ****      � ****� o      �� 0 msg  �  � L   P R�� m   P Q�� ���  � C  2 5��� o   2 3�� 0 _str  � m   3 4�� ���   � ��� V   X ���� Q   ` |���� r   c r��� c   c p��� n   c n��� 7  d n���
� 
cobj� m   h j�� � m   k m����� o   c d�
�
 0 _str  � m   n o�	
�	 
ctxt� o      �� 0 _str  � R      ���
� .ascrerr ****      � ****�  �  � L   z |�� m   z {�� ���  � D   \ _��� o   \ ]�� 0 _str  � m   ] ^�� ���   � ��� L   � ��� o   � ��� 0 _str  �  �,       �� �������� �  � � ���������������������������  "0 bundler_version BUNDLER_VERSION�� 0 get_bundler_dir  �� 0 get_cache_dir  �� 0 load_bundler  �� 0 
_bootstrap  �� 0 _install_confirmation  �� 0 _pwd  �� 0 _prepare_cmd  �� 0 _check_icon  �� 0 
_check_dir  �� 0 _folder_exists  �� 0 _path_exists  �� 0 	_is_empty  �� 	0 _trim  � �� �������� 0 get_bundler_dir  ��  ��     ���������� $
�� afdrcusr
�� 
rtyp
�� 
ctxt
�� .earsffdralis        afdr
�� 
psxp�� ���l �,�%b   %� �� .�������� 0 get_cache_dir  ��  ��     ���������� ;
�� afdrcusr
�� 
rtyp
�� 
ctxt
�� .earsffdralis        afdr
�� 
psxp�� ���l �,�%b   %� �� K����	
���� 0 load_bundler  ��  ��  	 ������ 0 bundler_dir BUNDLER_DIR�� 0 
as_bundler  
 ������ t�� ����� 0 get_bundler_dir  �� 0 _folder_exists  �� 0 
_bootstrap  
�� .sysodelanull��� ��� nmbr
�� .sysoloadscpt        file�� 0)j+  E�O)�k+ e 
)j+ Y hO�j O��%E�O�j � �� ��������� 0 
_bootstrap  ��  ��   ������������������ 0 bundler_dir BUNDLER_DIR�� 0 	cache_dir 	CACHE_DIR�� 0 urls URLs�� 0 _zipfile  �� 0 _url  �� 0 _status  �� 0 _cmd  �� 0 
as_bundler   "���������� � � � ��� ������� � ��	������7<P��W��g�������� 0 get_bundler_dir  �� 0 get_cache_dir  �� 0 _install_confirmation  ��  ��  
�� 
strq
�� 
kocl
�� 
cobj
�� .corecnte****       ****
�� .sysoexecTEXT���     TEXT
�� 
errn�� �� 0 
_check_dir  �� 0 _path_exists  
�� .sysodelanull��� ��� nmbr
�� 
psxf
�� 
alis
�� .coredeloobj        obj �� �)j+  E�O)j+ E�O 
)j+ W 	X  fO�b   %�%�b   %�%lvE�O��,�%E�O 3�[��l kh �%�%�%a %j E�O�a   Y h[OY��O�a  )a a la Y hO)�k+ Oa ��,%a %��,%E�O�j O�a %E�O h)�k+ a j [OY��Oa  *a �/a  &j !UOh� ��s�������� 0 _install_confirmation  ��  ��   �������������� 
0 _plist  �� 0 _cmd  �� 	0 _name  �� 	0 _icon  �� 	0 _text  �� 0 	_response   ��������������������������������������� $�� 0 _pwd  
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
errn�� �� �)j+  �%E�O�%�%E�O�j E�O)j+  �%E�O)�k+ E�O��%�%�%E�O�����mv�m��%a *a �/a  a ,E�O�a   eY hO�a    a  	a j UO)a a la Y hO�a   )a a la Y h� ��5�������� 0 _pwd  ��  ��   ������ 0 astid ASTID�� 	0 _path   
����K������������j
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
TEXT�� 9��,�lvE[�k/E�Z[�l/��,FZO)j �,[�\[Zk\Z�2�&�%E�O���,FO�� ��~�������� 0 _prepare_cmd  �� ����   ���� 0 _cmd  ��   �������� 0 _cmd  �� 0 pwd  �� 0 testing_var   ��������� 0 _pwd  
�� 
strq�� )j+  �,E�O�E�O��%�%�%�%� ����������� 0 _check_icon  �� ����   ���� 	0 _icon  ��   ���� 	0 _icon   ��~�}�|�
� 
psxf
�~ 
alis�}  �|  ��  *�/�&O�W 	X  �  �{��z�y�x�{ 0 
_check_dir  �z �w�w   �v�v 0 _folder  �y   �u�u 0 _folder   �t��s�r�t 0 _folder_exists  
�s 
strq
�r .sysoexecTEXT���     TEXT�x )�k+   ��,%j Y hO� �q��p�o�n�q 0 _folder_exists  �p �m�m   �l�l 0 _folder  �o   �k�k 0 _folder   �j�i�h�g�j 0 _path_exists  
�i 
ditm
�h 
pcls
�g 
cfol�n )�k+   � *�/�,� UY hOf �f �e�d�c�f 0 _path_exists  �e �b�b   �a�a 	0 _path  �d   �`�_�` 	0 _path  �_ 0 msg   
�^�]�\�[�ZKW�Y�X�W
�^ 
msng�] 0 	_is_empty  
�\ 
bool
�[ 
pcls
�Z 
alis
�Y 
psxf�X 0 msg  �W  �c Z�� 
 
)�k+ �& fY hO 9��,�  eY hO�� *�/EOeY �� *�/�&OeY fW 	X  	f �Vj�U�T !�S�V 0 	_is_empty  �U �R"�R "  �Q�Q 0 _obj  �T    �P�P 0 _obj  ! �O�N�M
�O 
msng�N 	0 _trim  
�M 
leng�S )eflv� fY hO��  eY hO)�k+ �,j  �L��K�J#$�I�L 	0 _trim  �K �H%�H %  �G�G 0 _str  �J  # �F�E�F 0 _str  �E 0 msg  $ �D�C�B�A�@���?�>�=���<�;�
�D 
pcls
�C 
ctxt
�B 
TEXT
�A 
bool
�@ 
msng
�? 
cobj�> 0 msg  �=  �<���;  �I ���,�
 	��,��&
 �� �& �Y hO��  �Y hO (h�� �[�\[Zl\Zi2�&E�W 	X  	�[OY��O (h�� �[�\[Zk\Z�2�&E�W 	X  	�[OY��O� ascr  ��ޭ