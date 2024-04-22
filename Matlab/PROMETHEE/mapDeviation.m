function [P,d]=mapDeviation(NoOfAlternatives,NoOfCriteria,E,PrefFun,q,p,s)
	%variables initiation
	d=zeros(NoOfAlternatives,NoOfAlternatives,NoOfCriteria);
	P=zeros(NoOfAlternatives,NoOfAlternatives,NoOfCriteria);
	%computation of fuzzy devation and mapping to unicriterion preference degrees
	for i=1:NoOfAlternatives
		for j=1:NoOfAlternatives
			if i~=j
				for k=1:NoOfCriteria
					%deviation
                    d(i,j,k)=E(i,k)-E(j,k);
					%usual criterion				
					if PrefFun(k)==1
                        if d(i,j,k)<=0
                            P(i,j,k)=0;
                        else
                            P(i,j,k)=1;
                        end
					%U-shape criterion
					elseif PrefFun(k)==2
                        if d(i,j,k)<=q(k)
                            P(i,j,k)=0;
                        else
                            P(i,j,k)=1;
                        end
					%V-shape criterion
					elseif PrefFun(k)==3
                        if d(i,j,k)<=0
                            P(i,j,k)=0;
                        elseif d(i,j,k)>0 && d(i,j,k)<=p(k)
                            P(i,j,k)=d(i,j,k)/p(k);
                        else
                            P(i,j,k)=1;
                        end
					%U-shape criterion
					elseif PrefFun(k)==4
                        if d(i,j,k)<=q(k)
                            P(i,j,k)=0;
                        elseif d(i,j,k)>q(k) && d(i,j,k)<=p(k)
                            P(i,j,k)=0.5;
                        else
                            P(i,j,k)=1;
                        end
					%V-shape with indifference area criterion
					elseif PrefFun(k)==5
                        if d(i,j,k)<=q(k)
                            P(i,j,k)=0;
                        elseif d(i,j,k)>q(k) && d(i,j,k)<=p(k)
                            P(i,j,k)=(d(i,j,k)-q(k))/(p(k)-q(k));
                        else
                            P(i,j,k)=1;
                        end
					%Gaussian criterion
					elseif PrefFun(k)==6
                        if d(i,j,k)<=0
                            P(i,j,k)=0;
                        else
                            P(i,j,k)=1-exp(-d(i,j,k)^2/(2*s(k)^2));
                        end
                    end
				end
			end
		end
	end
end