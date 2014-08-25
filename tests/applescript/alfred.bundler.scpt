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
 ; ; � < < � L i b r a r y / C a c h e s / c o m . r u n n i n g w i t h c r a y o n s . A l f r e d - 2 / W o r k f l o w   D a t a / a l f r e d . b u n d l e r - 1 o    ���� "0 bundler_version BUNDLER_VERSION ,  = > = l     ��������  ��  ��   >  ? @ ? l      �� A B��   A   MAIN API FUNCTION     B � C C &   M A I N   A P I   F U N C T I O N   @  D E D l     ��������  ��  ��   E  F G F l     ��������  ��  ��   G  H I H l     ��������  ��  ��   I  J K J i     L M L I      �������� 0 load_bundler  ��  ��   M k     / N N  O P O l      �� Q R��   Q � � Load `AlfredBundler.scpt` from the Alfred-Bundler directory as a script object. 
	If the Alfred-Bundler directory does not exist, install it (using `_bootstrap()`).

	:returns: the script object of `AlfredBundler.scpt`
	:rtype: ``script object``

	    R � S S�   L o a d   ` A l f r e d B u n d l e r . s c p t `   f r o m   t h e   A l f r e d - B u n d l e r   d i r e c t o r y   a s   a   s c r i p t   o b j e c t .   
 	 I f   t h e   A l f r e d - B u n d l e r   d i r e c t o r y   d o e s   n o t   e x i s t ,   i n s t a l l   i t   ( u s i n g   ` _ b o o t s t r a p ( ) ` ) . 
 
 	 : r e t u r n s :   t h e   s c r i p t   o b j e c t   o f   ` A l f r e d B u n d l e r . s c p t ` 
 	 : r t y p e :   ` ` s c r i p t   o b j e c t ` ` 
 
 	 P  T U T r      V W V n     X Y X I    �������� 0 get_bundler_dir  ��  ��   Y  f      W o      ���� 0 bundler_dir BUNDLER_DIR U  Z [ Z l   �� \ ]��   \ , &# Check if Alfred-Bundler is installed    ] � ^ ^ L #   C h e c k   i f   A l f r e d - B u n d l e r   i s   i n s t a l l e d [  _ ` _ Z     a b���� a >    c d c l    e���� e n    f g f I   	 �� h���� 0 _folder_exists   h  i�� i o   	 
���� 0 bundler_dir BUNDLER_DIR��  ��   g  f    	��  ��   d m    ��
�� boovtrue b k     j j  k l k l   �� m n��   m  # install it if not    n � o o & #   i n s t a l l   i t   i f   n o t l  p�� p n    q r q I    �������� 0 
_bootstrap  ��  ��   r  f    ��  ��  ��   `  s t s I   "�� u��
�� .sysodelanull��� ��� nmbr u m     v v ?���������   t  w x w l  # #�� y z��   y ? 9# Path to `AlfredBundler.scpt` in Alfed-Bundler directory    z � { { r #   P a t h   t o   ` A l f r e d B u n d l e r . s c p t `   i n   A l f e d - B u n d l e r   d i r e c t o r y x  | } | r   # ( ~  ~ l  # & ����� � b   # & � � � o   # $���� 0 bundler_dir BUNDLER_DIR � m   $ % � � � � � 6 / b u n d l e r / A l f r e d B u n d l e r . s c p t��  ��    o      ���� 0 
as_bundler   }  � � � l  ) )�� � ���   �  # Return script object    � � � � , #   R e t u r n   s c r i p t   o b j e c t �  ��� � L   ) / � � I  ) .�� ���
�� .sysoloadscpt        file � o   ) *���� 0 
as_bundler  ��  ��   K  � � � l     ��������  ��  ��   �  � � � l      �� � ���   �   AUTO-DOWNLOAD BUNDLER     � � � � .   A U T O - D O W N L O A D   B U N D L E R   �  � � � l     ��������  ��  ��   �  � � � i     � � � I      �������� 0 
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
�� .sysoexecTEXT���     TEXT � b   R ] � � � b   R Y � � � b   R W � � � b   R U � � � m   R S   � Z c u r l   - f s S L   - - c r e a t e - d i r s   - - c o n n e c t - t i m e o u t   5   � o   S T���� 0 _url   � m   U V �    - o   � o   W X���� 0 _zipfile   � m   Y \ �    & &   e c h o   $ ?��  ��  ��   � o      �� 0 _status   � �~ Z  d q�}�| =  d i	
	 o   d e�{�{ 0 _status  
 m   e h �  0  S   l m�}  �|  �~  �� 0 _url   � o   E F�z�z 0 urls URLs �  l  w w�y�y   # # Could not download the file    � : #   C o u l d   n o t   d o w n l o a d   t h e   f i l e  Z  w ��x�w >  w | o   w x�v�v 0 _status   m   x { �  0 R    ��u
�u .ascrerr ****      � **** m   � � � N C o u l d   n o t   d o w n l o a d   b u n d l e r   i n s t a l l   f i l e �t�s
�t 
errn m   � ��r�r �s  �x  �w     l  � ��q!"�q  ! L F# Ensure directory tree already exists for bundler to be moved into it   " �## � #   E n s u r e   d i r e c t o r y   t r e e   a l r e a d y   e x i s t s   f o r   b u n d l e r   t o   b e   m o v e d   i n t o   i t  $%$ n  � �&'& I   � ��p(�o�p 0 
_check_dir  ( )�n) o   � ��m�m 0 bundler_dir BUNDLER_DIR�n  �o  '  f   � �% *+* l  � ��l,-�l  , ; 5# Unzip the bundler and move it to its data directory   - �.. j #   U n z i p   t h e   b u n d l e r   a n d   m o v e   i t   t o   i t s   d a t a   d i r e c t o r y+ /0/ r   � �121 b   � �343 b   � �565 b   � �787 m   � �99 �::  c d  8 l  � �;�k�j; n   � �<=< 1   � ��i
�i 
strq= o   � ��h�h 0 	cache_dir 	CACHE_DIR�k  �j  6 m   � �>> �?? l ;   c d   i n s t a l l e r ;   u n z i p   - q o   b u n d l e r . z i p ;   m v   . / * / b u n d l e r  4 l  � �@�g�f@ n   � �ABA 1   � ��e
�e 
strqB o   � ��d�d 0 bundler_dir BUNDLER_DIR�g  �f  2 o      �c�c 0 _cmd  0 CDC I  � ��bE�a
�b .sysoexecTEXT���     TEXTE o   � ��`�` 0 _cmd  �a  D FGF l  � ��_HI�_  H Q K# Wait until bundler is fully unzipped and written to disk before finishing   I �JJ � #   W a i t   u n t i l   b u n d l e r   i s   f u l l y   u n z i p p e d   a n d   w r i t t e n   t o   d i s k   b e f o r e   f i n i s h i n gG KLK r   � �MNM l  � �O�^�]O b   � �PQP o   � ��\�\ 0 bundler_dir BUNDLER_DIRQ m   � �RR �SS 6 / b u n d l e r / A l f r e d B u n d l e r . s c p t�^  �]  N o      �[�[ 0 
as_bundler  L TUT V   � �VWV I  � ��ZX�Y
�Z .sysodelanull��� ��� nmbrX m   � �YY ?ə������Y  W H   � �ZZ l  � �[�X�W[ n  � �\]\ I   � ��V^�U�V 0 _path_exists  ^ _�T_ o   � ��S�S 0 
as_bundler  �T  �U  ]  f   � ��X  �W  U `a` O  � �bcb I  � ��Rd�Q
�R .coredeloobj        obj d l  � �e�P�Oe c   � �fgf 4   � ��Nh
�N 
psxfh o   � ��M�M 0 	cache_dir 	CACHE_DIRg m   � ��L
�L 
alis�P  �O  �Q  c m   � �ii�                                                                                  MACS  alis    t  Macintosh HD               ����H+  ҍK
Finder.app                                                     ԲY�`�        ����  	                CoreServices    ���*      �`D    ҍKҍHҍG  6Macintosh HD:System: Library: CoreServices: Finder.app   
 F i n d e r . a p p    M a c i n t o s h   H D  &System/Library/CoreServices/Finder.app  / ��  a j�Kj L   � ��J�J  �K   � klk l     �I�H�G�I  �H  �G  l mnm l     �Fop�F  o ; 5# Function to get confirmation to install the bundler   p �qq j #   F u n c t i o n   t o   g e t   c o n f i r m a t i o n   t o   i n s t a l l   t h e   b u n d l e rn rsr i    tut I      �E�D�C�E 0 _install_confirmation  �D  �C  u k     �vv wxw l      �Byz�B  y � � Ask user for permission to install Alfred-Bundler. 
	Allow user to go to website for more information, or even to cancel download.

	:returns: ``True`` or raises Error

	   z �{{V   A s k   u s e r   f o r   p e r m i s s i o n   t o   i n s t a l l   A l f r e d - B u n d l e r .   
 	 A l l o w   u s e r   t o   g o   t o   w e b s i t e   f o r   m o r e   i n f o r m a t i o n ,   o r   e v e n   t o   c a n c e l   d o w n l o a d . 
 
 	 : r e t u r n s :   ` ` T r u e ` `   o r   r a i s e s   E r r o r 
 
 	x |}| l     �A~�A  ~ 0 *# Get path to workflow's `info.plist` file    ��� T #   G e t   p a t h   t o   w o r k f l o w ' s   ` i n f o . p l i s t `   f i l e} ��� r     	��� b     ��� n    ��� I    �@�?�>�@ 0 _pwd  �?  �>  �  f     � m    �� ���  i n f o . p l i s t� o      �=�= 
0 _plist  � ��� l  
 
�<���<  � 5 /# Get name of workflow's from `info.plist` file   � ��� ^ #   G e t   n a m e   o f   w o r k f l o w ' s   f r o m   ` i n f o . p l i s t `   f i l e� ��� r   
 ��� b   
 ��� b   
 ��� m   
 �� ��� T / u s r / l i b e x e c / P l i s t B u d d y   - c   ' P r i n t   : n a m e '   '� o    �;�; 
0 _plist  � m    �� ���  '� o      �:�: 0 _cmd  � ��� r    ��� I   �9��8
�9 .sysoexecTEXT���     TEXT� o    �7�7 0 _cmd  �8  � o      �6�6 	0 _name  � ��� l   �5���5  � 6 0# Get workflow's icon, or default to system icon   � ��� ` #   G e t   w o r k f l o w ' s   i c o n ,   o r   d e f a u l t   t o   s y s t e m   i c o n� ��� r    #��� b    !��� n   ��� I    �4�3�2�4 0 _pwd  �3  �2  �  f    � m     �� ���  i c o n . p n g� o      �1�1 	0 _icon  � ��� r   $ ,��� n  $ *��� I   % *�0��/�0 0 _check_icon  � ��.� o   % &�-�- 	0 _icon  �.  �/  �  f   $ %� o      �,�, 	0 _icon  � ��� l  - -�+���+  � / )# Prepare explanation text for dialog box   � ��� R #   P r e p a r e   e x p l a n a t i o n   t e x t   f o r   d i a l o g   b o x� ��� r   - 6��� b   - 4��� b   - 2��� b   - 0��� o   - .�*�* 	0 _name  � m   . /�� ���   n e e d s   t o   i n s t a l l   a d d i t i o n a l   c o m p o n e n t s ,   w h i c h   w i l l   b e   p l a c e d   i n   t h e   A l f r e d   s t o r a g e   d i r e c t o r y   a n d   w i l l   n o t   i n t e r f e r e   w i t h   y o u r   s y s t e m . 
 
 Y o u   m a y   b e   a s k e d   t o   a l l o w   s o m e   c o m p o n e n t s   t o   r u n ,   d e p e n d i n g   o n   y o u r   s e c u r i t y   s e t t i n g s . 
 
 Y o u   c a n   d e c l i n e   t h i s   i n s t a l l a t i o n ,   b u t  � o   0 1�)�) 	0 _name  � m   2 3�� ��� �   m a y   n o t   w o r k   w i t h o u t   t h e m .   T h e r e   w i l l   b e   a   s l i g h t   d e l a y   a f t e r   a c c e p t i n g .� o      �(�( 	0 _text  � ��� l  7 7�'�&�%�'  �&  �%  � ��� r   7 Y��� n   7 W��� 1   S W�$
�$ 
bhit� l  7 S��#�"� I  7 S�!��
�! .sysodlogaskr        TEXT� o   7 8� �  	0 _text  � ���
� 
btns� J   9 >�� ��� m   9 :�� ���  M o r e   I n f o� ��� m   : ;�� ���  C a n c e l� ��� m   ; <�� ���  P r o c e e d�  � ���
� 
dflt� m   ? @�� � ���
� 
appr� b   A D��� m   A B�� ���  S e t u p  � o   B C�� 	0 _name  � ���
� 
disp� 4   G M��
� 
psxf� o   K L�� 	0 _icon  �  �#  �"  � o      �� 0 	_response  � ��� l  Z Z����  � 0 *# If permission granted, continue download   � ��� T #   I f   p e r m i s s i o n   g r a n t e d ,   c o n t i n u e   d o w n l o a d� ��� Z  Z h����� =  Z _��� o   Z [�� 0 	_response  � m   [ ^�� ���  P r o c e e d� L   b d�� m   b c�
� boovtrue�  �  � ��� l  i i����  � 6 0# If more info requested, open webpage and error   � �   ` #   I f   m o r e   i n f o   r e q u e s t e d ,   o p e n   w e b p a g e   a n d   e r r o r�  Z   i ��� =  i n o   i j�� 0 	_response   m   j m �  M o r e   I n f o k   q �		 

 O   q  I  w ~��

� .GURLGURLnull��� ��� TEXT m   w z � � h t t p s : / / g i t h u b . c o m / s h a w n r i c e / a l f r e d - b u n d l e r / w i k i / W h a t - i s - t h e - A l f r e d - B u n d l e r�
   m   q t�                                                                                  sevs  alis    �  Macintosh HD               ����H+  ҍKSystem Events.app                                              �U'�A��        ����  	                CoreServices    ���*      �A�9    ҍKҍHҍG  =Macintosh HD:System: Library: CoreServices: System Events.app   $  S y s t e m   E v e n t s . a p p    M a c i n t o s h   H D  -System/Library/CoreServices/System Events.app   / ��   �	 R   � ��
� .ascrerr ****      � **** m   � � � F U s e r   l o o k e d   s o u g h t   m o r e   i n f o r m a t i o n ��
� 
errn m   � ��� �  �	  �  �    l  � ���   , &# If permission denied, stop and error    � L #   I f   p e r m i s s i o n   d e n i e d ,   s t o p   a n d   e r r o r � Z  � ��� =  � � !  o   � �� �  0 	_response  ! m   � �"" �##  C a n c e l R   � ���$%
�� .ascrerr ****      � ****$ m   � �&& �'' D U s e r   c a n c e l e d   b u n d l e r   i n s t a l l a t i o n% ��(��
�� 
errn( m   � ����� ��  �  �  �  s )*) l     ��������  ��  ��  * +,+ l     ��������  ��  ��  , -.- l      ��/0��  /   HELPER HANDLERS    0 �11 "   H E L P E R   H A N D L E R S  . 232 l     ��������  ��  ��  3 454 i    676 I      �������� 0 _pwd  ��  ��  7 k     888 9:9 l      ��;<��  ; � � Get path to "present working directory", i.e. the workflow's root directory.
	
	:returns: Path to this script's parent directory
	:rtype: ``string`` (POSIX path)

	   < �==J   G e t   p a t h   t o   " p r e s e n t   w o r k i n g   d i r e c t o r y " ,   i . e .   t h e   w o r k f l o w ' s   r o o t   d i r e c t o r y . 
 	 
 	 : r e t u r n s :   P a t h   t o   t h i s   s c r i p t ' s   p a r e n t   d i r e c t o r y 
 	 : r t y p e :   ` ` s t r i n g ` `   ( P O S I X   p a t h ) 
 
 	: >?> l     ��@A��  @ = 7# Save default AS delimiters, and set delimiters to "/"   A �BB n #   S a v e   d e f a u l t   A S   d e l i m i t e r s ,   a n d   s e t   d e l i m i t e r s   t o   " / "? CDC r     EFE J     GG HIH n    JKJ 1    ��
�� 
txdlK 1     ��
�� 
ascrI L��L m    MM �NN  /��  F J      OO PQP o      ���� 0 astid ASTIDQ R��R n     STS 1    ��
�� 
txdlT 1    ��
�� 
ascr��  D UVU l   ��WX��  W , &# Get POSIX path of script's directory   X �YY L #   G e t   P O S I X   p a t h   o f   s c r i p t ' s   d i r e c t o r yV Z[Z r    /\]\ b    -^_^ l   +`����` c    +aba n    )cdc 7   )��ef
�� 
citme m   # %���� f m   & (������d l   g����g n    hih 1    ��
�� 
psxpi l   j����j I   ��k��
�� .earsffdralis        afdrk  f    ��  ��  ��  ��  ��  b m   ) *��
�� 
TEXT��  ��  _ m   + ,ll �mm  /] o      ���� 	0 _path  [ non l  0 0��pq��  p . (# Reset AS delimiters to original values   q �rr P #   R e s e t   A S   d e l i m i t e r s   t o   o r i g i n a l   v a l u e so sts r   0 5uvu o   0 1���� 0 astid ASTIDv n     wxw 1   2 4��
�� 
txdlx 1   1 2��
�� 
ascrt y��y L   6 8zz o   6 7���� 	0 _path  ��  5 {|{ l     ��������  ��  ��  | }~} i    � I      ������� 0 _prepare_cmd  � ���� o      ���� 0 _cmd  ��  ��  � k     �� ��� l      ������  �,& Ensure shell `_cmd` is working from the property directory.
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
 �� ��� 0 e x p o r t   A B _ B R A N C H = d e v e l ;  � o      ���� 0 testing_var  � ��� l   ������  � 7 1# return shell script where `pwd` is properly set   � ��� b #   r e t u r n   s h e l l   s c r i p t   w h e r e   ` p w d `   i s   p r o p e r l y   s e t� ���� L    �� b    ��� b    ��� b    ��� b    ��� o    ���� 0 testing_var  � m    �� ���  c d  � o    ���� 0 pwd  � m    �� ���  ;   b a s h  � o    ���� 0 _cmd  ��  ~ ��� l     ��������  ��  ��  � ��� i    "��� I      ������� 0 _check_icon  � ���� o      ���� 	0 _icon  ��  ��  � k     �� ��� l      ������  � � � Check if `_icon` exists, and if not revert to system download icon.

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
strq� o    ���� 0 _folder  ��  ��  ��  ��  ��  � ���� L    �� o    ���� 0 _folder  ��  � ��� l     ��������  ��  ��  � ��� l     ��������  ��  ��  � ��� i   ' *��� I      �� ���� 0 _folder_exists    �� o      ���� 0 _folder  ��  ��  � k       l      ����   � � Return ``true`` if `_folder` exists, else ``false``

	:param _folder: Full path to directory
	:type _folder: ``string`` (POSIX path)
	:returns: ``Boolean``

	    �>   R e t u r n   ` ` t r u e ` `   i f   ` _ f o l d e r `   e x i s t s ,   e l s e   ` ` f a l s e ` ` 
 
 	 : p a r a m   _ f o l d e r :   F u l l   p a t h   t o   d i r e c t o r y 
 	 : t y p e   _ f o l d e r :   ` ` s t r i n g ` `   ( P O S I X   p a t h ) 
 	 : r e t u r n s :   ` ` B o o l e a n ` ` 
 
 	 	 Z     
����
 n     I    ������ 0 _path_exists   �� o    ���� 0 _folder  ��  ��    f      O   	  L     l   ��� =    n     m    �~
�~ 
pcls l   �}�| 4    �{
�{ 
ditm o    �z�z 0 _folder  �}  �|   m    �y
�y 
cfol��  �   m   	 
�                                                                                  sevs  alis    �  Macintosh HD               ����H+  ҍKSystem Events.app                                              �U'�A��        ����  	                CoreServices    ���*      �A�9    ҍKҍHҍG  =Macintosh HD:System: Library: CoreServices: System Events.app   $  S y s t e m   E v e n t s . a p p    M a c i n t o s h   H D  -System/Library/CoreServices/System Events.app   / ��  ��  ��  	 �x L     m    �w
�w boovfals�x  �  l     �v�u�t�v  �u  �t     i   + .!"! I      �s#�r�s 0 _path_exists  # $�q$ o      �p�p 	0 _path  �q  �r  " k     Y%% &'& l      �o()�o  ( � � Return ``true`` if `_path` exists, else ``false``

	:param _path: Any POSIX path (file or folder)
	:type _path: ``string`` (POSIX path)
	:returns: ``Boolean``

	   ) �**D   R e t u r n   ` ` t r u e ` `   i f   ` _ p a t h `   e x i s t s ,   e l s e   ` ` f a l s e ` ` 
 
 	 : p a r a m   _ p a t h :   A n y   P O S I X   p a t h   ( f i l e   o r   f o l d e r ) 
 	 : t y p e   _ p a t h :   ` ` s t r i n g ` `   ( P O S I X   p a t h ) 
 	 : r e t u r n s :   ` ` B o o l e a n ` ` 
 
 	' +,+ Z    -.�n�m- G     /0/ =    121 o     �l�l 	0 _path  2 m    �k
�k 
msng0 n   343 I    �j5�i�j 0 	_is_empty  5 6�h6 o    �g�g 	0 _path  �h  �i  4  f    . L    77 m    �f
�f boovfals�n  �m  , 8�e8 Q    Y9:;9 k    O<< =>= Z   )?@�d�c? =    ABA n    CDC m    �b
�b 
pclsD o    �a�a 	0 _path  B m    �`
�` 
alis@ L   # %EE m   # $�_
�_ boovtrue�d  �c  > F�^F Z   * OGHIJG E   * -KLK o   * +�]�] 	0 _path  L m   + ,MM �NN  :H k   0 8OO PQP 4   0 5�\R
�\ 
alisR o   2 3�[�[ 	0 _path  Q S�ZS L   6 8TT m   6 7�Y
�Y boovtrue�Z  I UVU E   ; >WXW o   ; <�X�X 	0 _path  X m   < =YY �ZZ  /V [�W[ k   A J\\ ]^] c   A G_`_ 4   A E�Va
�V 
psxfa o   C D�U�U 	0 _path  ` m   E F�T
�T 
alis^ b�Sb L   H Jcc m   H I�R
�R boovtrue�S  �W  J L   M Odd m   M N�Q
�Q boovfals�^  : R      �Pe�O
�P .ascrerr ****      � ****e o      �N�N 0 msg  �O  ; L   W Yff m   W X�M
�M boovfals�e    ghg l     �L�K�J�L  �K  �J  h iji i   / 2klk I      �Im�H�I 0 	_is_empty  m n�Gn o      �F�F 0 _obj  �G  �H  l k     (oo pqp l      �Ers�E  r � � Return ``true`` if `_obj ` is empty, else ``false``

	:param _obj: Any Applescript type
	:type _obj: (optional)
	:returns: ``Boolean``
		
	   s �tt   R e t u r n   ` ` t r u e ` `   i f   ` _ o b j   `   i s   e m p t y ,   e l s e   ` ` f a l s e ` ` 
 
 	 : p a r a m   _ o b j :   A n y   A p p l e s c r i p t   t y p e 
 	 : t y p e   _ o b j :   ( o p t i o n a l ) 
 	 : r e t u r n s :   ` ` B o o l e a n ` ` 
 	 	 
 	q uvu l     �Dwx�D  w ! # Is `_obj ` a ``Boolean``?   x �yy 6 #   I s   ` _ o b j   `   a   ` ` B o o l e a n ` ` ?v z{z Z    |}�C�B| E     ~~ J     �� ��� m     �A
�A boovtrue� ��@� m    �?
�? boovfals�@   o    �>�> 0 _obj  } L   	 �� m   	 
�=
�= boovfals�C  �B  { ��� l   �<���<  � ' !# Is `_obj ` a ``missing value``?   � ��� B #   I s   ` _ o b j   `   a   ` ` m i s s i n g   v a l u e ` ` ?� ��� Z   ���;�:� =   ��� o    �9�9 0 _obj  � m    �8
�8 
msng� L    �� m    �7
�7 boovtrue�;  �:  � ��� l   �6���6  � " # Is `_obj ` a empty string?   � ��� 8 #   I s   ` _ o b j   `   a   e m p t y   s t r i n g ?� ��5� L    (�� =   '��� n    %��� 1   # %�4
�4 
leng� l   #��3�2� n   #��� I    #�1��0�1 	0 _trim  � ��/� o    �.�. 0 _obj  �/  �0  �  f    �3  �2  � m   % &�-�-  �5  j ��� l     �,�+�*�,  �+  �*  � ��)� i   3 6��� I      �(��'�( 	0 _trim  � ��&� o      �%�% 0 _str  �&  �'  � k     ��� ��� l      �$���$  � � � Remove white space from beginning and end of `_str`

	:param _str: A text string
	:type _str: ``string``
	:returns: trimmed string

	   � ���   R e m o v e   w h i t e   s p a c e   f r o m   b e g i n n i n g   a n d   e n d   o f   ` _ s t r ` 
 
 	 : p a r a m   _ s t r :   A   t e x t   s t r i n g 
 	 : t y p e   _ s t r :   ` ` s t r i n g ` ` 
 	 : r e t u r n s :   t r i m m e d   s t r i n g 
 
 	� ��� Z     ���#�"� G     ��� G     ��� >    ��� n     ��� m    �!
�! 
pcls� o     � �  0 _str  � m    �
� 
ctxt� >   ��� n    ��� m   	 �
� 
pcls� o    	�� 0 _str  � m    �
� 
TEXT� =   ��� o    �� 0 _str  � m    �
� 
msng� L    �� o    �� 0 _str  �#  �"  � ��� Z  ! -����� =  ! $��� o   ! "�� 0 _str  � m   " #�� ���  � L   ' )�� o   ' (�� 0 _str  �  �  � ��� V   . W��� Q   6 R���� r   9 H��� c   9 F��� n   9 D��� 7  : D���
� 
cobj� m   > @�� � m   A C����� o   9 :�� 0 _str  � m   D E�
� 
ctxt� o      �� 0 _str  � R      ���
� .ascrerr ****      � ****� o      �� 0 msg  �  � L   P R�� m   P Q�� ���  � C  2 5��� o   2 3�� 0 _str  � m   3 4�� ���   � ��� V   X ���� Q   ` |���� r   c r��� c   c p��� n   c n��� 7  d n�
��
�
 
cobj� m   h j�	�	 � m   k m����� o   c d�� 0 _str  � m   n o�
� 
ctxt� o      �� 0 _str  � R      ���
� .ascrerr ****      � ****�  �  � L   z |�� m   z {�� ���  � D   \ _��� o   \ ]�� 0 _str  � m   ] ^�� ���   � �� � L   � ��� o   � ����� 0 _str  �   �)       ��� ������ ��  � ������������������������������ "0 bundler_version BUNDLER_VERSION�� 0 get_bundler_dir  �� 0 get_cache_dir  �� 0 load_bundler  �� 0 
_bootstrap  �� 0 _install_confirmation  �� 0 _pwd  �� 0 _prepare_cmd  �� 0 _check_icon  �� 0 
_check_dir  �� 0 _folder_exists  �� 0 _path_exists  �� 0 	_is_empty  �� 	0 _trim  � �� �������� 0 get_bundler_dir  ��  ��     ���������� $
�� afdrcusr
�� 
rtyp
�� 
ctxt
�� .earsffdralis        afdr
�� 
psxp�� ���l �,�%b   %� �� .����	
���� 0 get_cache_dir  ��  ��  	  
 ���������� ;
�� afdrcusr
�� 
rtyp
�� 
ctxt
�� .earsffdralis        afdr
�� 
psxp�� ���l �,�%b   %� �� M�������� 0 load_bundler  ��  ��   ������ 0 bundler_dir BUNDLER_DIR�� 0 
as_bundler   ������ v�� ����� 0 get_bundler_dir  �� 0 _folder_exists  �� 0 
_bootstrap  
�� .sysodelanull��� ��� nmbr
�� .sysoloadscpt        file�� 0)j+  E�O)�k+ e 
)j+ Y hO�j O��%E�O�j � �� ��������� 0 
_bootstrap  ��  ��   ������������������ 0 bundler_dir BUNDLER_DIR�� 0 	cache_dir 	CACHE_DIR�� 0 urls URLs�� 0 _zipfile  �� 0 _url  �� 0 _status  �� 0 _cmd  �� 0 
as_bundler   "���������� � � � ��� ������� ��������9>R��Y��i�������� 0 get_bundler_dir  �� 0 get_cache_dir  �� 0 _install_confirmation  ��  ��  
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
)j+ W 	X  fO�b   %�%�b   %�%lvE�O��,�%E�O 3�[��l kh �%�%�%a %j E�O�a   Y h[OY��O�a  )a a la Y hO)�k+ Oa ��,%a %��,%E�O�j O�a %E�O h)�k+ a j [OY��Oa  *a �/a  &j !UOh� ��u�������� 0 _install_confirmation  ��  ��   �������������� 
0 _plist  �� 0 _cmd  �� 	0 _name  �� 	0 _icon  �� 	0 _text  �� 0 	_response   ���������������������������������������"&�� 0 _pwd  
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
errn�� �� �)j+  �%E�O�%�%E�O�j E�O)j+  �%E�O)�k+ E�O��%�%�%E�O�����mv�m��%a *a �/a  a ,E�O�a   eY hO�a    a  	a j UO)a a la Y hO�a   )a a la Y h� ��7�������� 0 _pwd  ��  ��   ������ 0 astid ASTID�� 	0 _path   
����M������������l
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
TEXT�� 9��,�lvE[�k/E�Z[�l/��,FZO)j �,[�\[Zk\Z�2�&�%E�O���,FO�  ����������� 0 _prepare_cmd  �� ����   ���� 0 _cmd  ��   �������� 0 _cmd  �� 0 pwd  �� 0 testing_var   ��������� 0 _pwd  
�� 
strq�� )j+  �,E�O�E�O��%�%�%�% ����������� 0 _check_icon  �� ��   �~�~ 	0 _icon  ��   �}�} 	0 _icon   �|�{�z�y�
�| 
psxf
�{ 
alis�z  �y  ��  *�/�&O�W 	X  � �x��w�v�u�x 0 
_check_dir  �w �t�t   �s�s 0 _folder  �v   �r�r 0 _folder   �q��p�o�q 0 _folder_exists  
�p 
strq
�o .sysoexecTEXT���     TEXT�u )�k+   ��,%j Y hO� �n��m�l�k�n 0 _folder_exists  �m �j�j   �i�i 0 _folder  �l   �h�h 0 _folder   �g�f�e�d�g 0 _path_exists  
�f 
ditm
�e 
pcls
�d 
cfol�k )�k+   � *�/�,� UY hOf �c"�b�a �`�c 0 _path_exists  �b �_!�_ !  �^�^ 	0 _path  �a   �]�\�] 	0 _path  �\ 0 msg    
�[�Z�Y�X�WMY�V�U�T
�[ 
msng�Z 0 	_is_empty  
�Y 
bool
�X 
pcls
�W 
alis
�V 
psxf�U 0 msg  �T  �` Z�� 
 
)�k+ �& fY hO 9��,�  eY hO�� *�/EOeY �� *�/�&OeY fW 	X  	f �Sl�R�Q"#�P�S 0 	_is_empty  �R �O$�O $  �N�N 0 _obj  �Q  " �M�M 0 _obj  # �L�K�J
�L 
msng�K 	0 _trim  
�J 
leng�P )eflv� fY hO��  eY hO)�k+ �,j  �I��H�G%&�F�I 	0 _trim  �H �E'�E '  �D�D 0 _str  �G  % �C�B�C 0 _str  �B 0 msg  & �A�@�?�>�=���<�;�:���9�8�
�A 
pcls
�@ 
ctxt
�? 
TEXT
�> 
bool
�= 
msng
�< 
cobj�; 0 msg  �:  �9���8  �F ���,�
 	��,��&
 �� �& �Y hO��  �Y hO (h�� �[�\[Zl\Zi2�&E�W 	X  	�[OY��O (h�� �[�\[Zk\Z�2�&E�W 	X  	�[OY��O� ascr  ��ޭ