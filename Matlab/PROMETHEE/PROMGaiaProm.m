function [Phi_net,Phi]=PROMGaiaProm(NoOfCriteria,NoOfVariants,E,W,D,PrefFun,q,p,s)
%PROMETHEE II
% NoOfCriteria - number of criteria
% NoOfVariants - number of variants
% E - decision matrix
% W - weights vector
% D - preference direction vector
% PrefFun - preferences function vector
% q - indifference thresholds vector
% p - preference thresholds vector

W=W./sum(W);
for i=1:NoOfCriteria
    if D(i)==2
        E(:,i)=E(:,i).*-1;
    end
end

Pp=zeros(NoOfVariants,NoOfVariants,NoOfCriteria);
Phi=zeros(NoOfVariants,NoOfCriteria);
Phi_net=zeros(NoOfVariants,1);

for i=1:NoOfVariants
    for j=1:NoOfVariants
        if i~=j
            for k=1:NoOfCriteria
                if PrefFun(k)==1
                    Pp(i,j,k)=E(i,k)>E(j,k);
                elseif PrefFun(k)==2
                    Pp(i,j,k)=E(i,k)>E(j,k)+q(k);
                elseif PrefFun(k)==3
                    Pp(i,j,k)=E(i,k)>E(j,k)+p(k);
                    if ~Pp(i,j,k)
                        Pp(i,j,k)=(E(i,k)-E(j,k))/p(k);
                        if Pp(i,j,k)<0
                            Pp(i,j,k)=0;
                        end
                    end
                elseif PrefFun(k)==4
					Pp(i,j,k)=E(i,k)>E(j,k)+p(k);
					if ~Pp(i,j,k)
						Pp(i,j,k)=(E(i,k)>E(j,k)+q(k))*(1/2);
                    end
                elseif PrefFun(k)==5
                    Pp(i,j,k)=E(i,k)>E(j,k)+p(k);
                    if ~Pp(i,j,k)
                        Pp(i,j,k)=(E(i,k)-E(j,k)-q(k))/(p(k)-q(k));
                        if (E(i,k)-E(j,k))<=q(k)
                            Pp(i,j,k)=0;
                        end
                    end
                elseif PrefFun(k)==6
                    if E(i,k)>E(j,k)
                        Pp(i,j,k)=1-eps^(-((E(i,k)-E(j,k))^2)/(2*s(k)^2));
                    end
                end
            end
        end
    end
end
for i=1:NoOfCriteria
    Phi(:,i)=sum(Pp(:,:,i)'-Pp(:,:,i))/(NoOfVariants-1);
end
for i=1:NoOfVariants
    Phi_net(i)=sum(Phi(i,:).*W);
end

                