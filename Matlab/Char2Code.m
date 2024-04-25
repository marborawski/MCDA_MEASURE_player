function r = Char2Code(d)
%Replacing character codes with codes used by the machine
%
% d - character code
% returns machine codes
  if d == 9 || d == ' ' || d == 13 || d == 10
    r = 1;
  elseif d == ':'
    r = 2;
  elseif d == '<'
    r = 3;
  elseif d == '>'
    r = 4;
  elseif d == '/'
    r = 5;
  elseif (d >= 'a' && d <= 'z') || (d >= 'A' && d <= 'Z') || d == '_'
    r = 6;
  elseif (d >= '0' && d <= '9')
    r = 7;
  elseif d == '"'
    r = 8;
  elseif d == '='
    r = 9;
  elseif d == '?'
    r = 10;
  else
    r = 11;
  end
end
