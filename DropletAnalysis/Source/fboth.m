  function fboth(f,varargin)
% function fboth(f,varargin)
%
% plottet auf Bildschirm und in File f (nur f�r f~=1)
% wenn f Vektor ist, wird 2. Element als Anzeige Detailinfos interpretiert = 0: kein Bildschirmplot, = 1 Bildschirmplot
% 
% wenn nur 1 Parameter dann anzeigen!
%
% Die Funktion fboth ist Teil der MATLAB-Toolbox Gait-CAD. 
% Copyright (C) 2007  [Ralf Mikut, Tobias Loose, Ole Burmeister, Sebastian Braun, Markus Reischl]


% Letztes �nderungsdatum: 10-May-2007 17:50:28
% 
% Dieses Programm ist freie Software. Sie k�nnen es unter den Bedingungen der GNU General Public License,
% wie von der Free Software Foundation ver�ffentlicht, weitergeben und/oder modifizieren, 
% entweder gem�� Version 2 der Lizenz oder jeder sp�teren Version.
% 
% Die Ver�ffentlichung dieses Programms erfolgt in der Hoffnung, dass es Ihnen von Nutzen sein wird,
% aber OHNE IRGENDEINE GARANTIE, sogar ohne die implizite Garantie der MARKTREIFE oder 
% der VERWENDBARKEIT F�R EINEN BESTIMMTEN ZWECK.
% Details finden Sie in der GNU General Public License.
% 
% Sie sollten ein Exemplar der GNU General Public License zusammen mit diesem Programm erhalten haben.
% Falls nicht, schreiben Sie an die Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110, USA.
% 
% Weitere Erl�uterungen zu Gait-CAD finden Sie in der beiliegenden Dokumentation oder im folgenden Konferenzbeitrag:
% 
% MIKUT, R.; BURMEISTER, O.; REISCHL, M.; LOOSE, T.:  Die MATLAB-Toolbox Gait-CAD. 
% In:  Proc., 16. Workshop Computational Intelligence, S. 114-124, Universit�tsverlag Karlsruhe, 2006
% Online verf�gbar unter: http://www.iai.fzk.de/projekte/biosignal/public_html/gaitcad.pdf
% 
% Bitte zitieren Sie diesen Beitrag, wenn Sie Gait-CAD f�r Ihre wissenschaftliche T�tigkeit verwenden.

if (length(f)==1) 
   f(2)=1;
end; 

%Bildschirmplot, wenn Anzeigeparameter gesetzt
if f(2)
   fprintf(1,varargin{:});
end;

%Fileplot, wenn File
if f(1)~=1 
   fprintf(f(1),varargin{:});
end;