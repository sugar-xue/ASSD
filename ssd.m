function [result,indices,stack_matrix, stack_y] = ssd(D,y,noiselev ) %This program aims to solve a undeterminated linear system by SSD algorithm. 
% Initialization 
y0 = y;
D0 = D;
[mmm, nnn] = size(D0); 
indices = []; %indices picked up 
remain = [1:nnn]; %indices remained in D 
kkk = 0; %times of iterations 
stack_matrix = zeros(nnn); %matrix constructed by decimation 
stack_y = zeros(nnn,1); %y constructed by decimation 
beta = zeros(mmm,1); %guidance vector 
maxiter = 1000;
result = zeros(nnn,1); 
kmax = mmm/log(mmm);
mu = 1; % stop when norm(y')<= mu2*noiselev; if noiselev hard to estimate set mu = 0;
% Iteration 
while (kkk <= kmax)  && norm(y) > noiselev*mu
    index = guidance_convex(D,y,beta,maxiter); %返回最大值的索引值
    indices = [indices;remain(index)]; %Put real index into the indices. 当前找出的所有索引值
    dindex = D(:,index); 
    dindex_2 = norm(dindex)^2; 
    for iii = 1:nnn-kkk 
        if iii == index 
            stack_matrix(kkk+1,remain(iii))=1; 
        else
            overlap_di_dindex = (D(:,iii)'*dindex) / dindex_2; 
            stack_matrix(kkk+1,remain(iii)) = overlap_di_dindex; 
            D(:,iii) = D(:,iii) - overlap_di_dindex * dindex; %%更新矩阵D
        end
    end
    overlap_y_dindex = (y'*dindex) / dindex_2;
    stack_y(kkk+1) = overlap_y_dindex; 
    y = y - overlap_y_dindex * dindex; %%更新向量z
    D(:,index) = []; 
    remain(index) = []; 
    kkk = kkk+1; 
%     disp([num2str(kkk),'th iteration is done. The residual y is ',num2str(norm(y)),'.']) 
    x_nonzero = stack_matrix(1:kkk,indices) \ stack_y(1:kkk); 
end 
%Solve and Output  
result(indices,1) = x_nonzero;
end