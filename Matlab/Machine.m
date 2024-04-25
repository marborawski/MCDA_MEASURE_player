function data2 = Machine(data,t)
%Machine that divides text into elements and assigns them codes for the final states of the machine
%
% data - text
% t    - table of transitions between the states of the machine
% returns an array of structures containing a text fragment (txt field) and the state assigned to it (state field)
    data2 = [];
    state = 1;
    ii = 1;
    while ii <= length(data)
      if state == 1
        txt = '';
      end
      state = t(Char2Code(data(ii)),state);
      txt = [txt data(ii)];
      switch state
% Final states
        case {3,5,9,11,14,16,18,19,21,24}
          if state == 19
              d.txt = txt(2:end-2);
          else
            d.txt = txt(1:end-1);
          end
          d.state = state;
          data2 = [data2 d];
          state = 1;
       otherwise
         ii = ii + 1;
      end
    end
    if state ~= 1
        switch state
          case {7,8,10,13,15,17,20,23}
            d.state = state + 1;
          otherwise
            d.state = state;
        end  
        d.txt = txt;
        data2 = [data2 d];
    end
end
