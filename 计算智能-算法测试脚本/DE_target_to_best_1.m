function [gbestx,gbestfitness,gbesthistory]=DE_target_to_best_1(popsize,dimension,xmax,xmin,vmax,vmin,maxiter,FuncId)
% Differential Evolution Algorithm: DE/current_to_best/1/bin
% popsize：种群大小
% dimension： 个体的维度
% maxiter： 迭代次数
% Funcid： 测试函数编号


%% 位置空间分配
x=rand(popsize,dimension); %位置向量
v=rand(popsize,dimension); %变异向量
u=rand(popsize,dimension); %试验向量
pbestx = rand(popsize,dimension);%存放个体的局部最优位置
gbestx = rand(1,dimension); % 存放全局最优位置

% 适应度空间分配
fitnessx= rand(1,popsize); % 群体适应度
pbestfitness= ones(popsize,1).*realmax;%局部最优适应度

gbesthistory=rand(maxiter,1); %记录每一代的最佳适应度数值,便于绘制收敛曲线

F = 0.6;
CR= 0.9;

ComputeFitness=@SimpleBenchmark;

%% 种群初始化
for i =1:popsize
    x(i,:)=xmin+(xmax-xmin).*rand(1,dimension);
    fitnessx(i)= ComputeFitness(x(i,:),FuncId); % 个体适应度
    pbestfitness(i)=fitnessx(i);
    pbestx(i,:)=x(i,:);
end

% 初始化全局最佳适应度和相应位置
[gbestfitness, id] = min(pbestfitness);
gbestx(:) = pbestx(id,:);

%% 循环迭代
iter =1;

 %% ******************【第一部分： 种群进化】 ******************
while iter<=maxiter
    
    for i =1:popsize
        %% 1.个体i执行变异操作，生成贡献向量v （编译后位置是否越界问题？）
        % 随机选择2个不同于i的整数
        r=selectID(popsize,i,2);
        
        r1=r(1);
        r2=r(2);
        
        % v(i,:)=x(i,:)+F*(pbestx(i,:)- x(i,:))+ F*(x(r1,:) - x(r2,:));
        v(i,:)=x(i,:)+F*(gbestx(1,:)- x(i,:))+ F*(x(r1,:) - x(r2,:));
        
        %% 2.个体i执行交叉操作，生成试验向量u
        jrand =randi([1,popsize],1);
        
        for j =1:dimension
            if(rand <= CR || j==jrand)
                u(i,j)=v(i,j);
            else
                u(i,j)=x(i,j);
            end
        end
        
        
        %% 3. 个体i执行贪婪选择，生成i对应的新一代种群（涉及适应度评估）
        ufitness = ComputeFitness(u(i,:),FuncId);
        if ufitness <= fitnessx(i)
            x(i,:) = u(i,:);      % 更新个体位置
            fitnessx(i)=ufitness; % 更新适应度
        end
        
        %% 4. 更新个体的全局最优位置
        if fitnessx(i)<= gbestfitness
            gbestfitness=fitnessx(i);
            gbestx(1,:) = x(i,:);
        end
       
        
    end % end each individual
    
    %% ******************【第二部分：记录最优】 ******************
    
    gbesthistory(iter)=gbestfitness;
    
    fprintf("算法算法DE/target-best/1,第%d代，最佳适应度 = %e\n",iter,gbestfitness);
    
    iter = iter+1;
    
end % end iter
end % end function

%% ---------------------------------------------------------------------

%% 选择不同的函数
function [r]=selectID(popsize,i,count)
% 函数功能：在[1,popsizze]内随机生成count个不包括i的彼此不重复的整数值
% 函数返回： 列向量r，向量的维度为count。
% 函数思想： 把已经选择的元素，从数组里去除。
if count<= popsize
    %1.除去i的值，生成新的向量vec
    vec=[1:i-1,i+1:popsize];
    
    %2.随机生成count个不一样的数值
    r=zeros(1,count);
    
    for j =1:count
        n = popsize-j;   % 当前vec中向量的个数
        t = randi(n,1,1);% 产生一个随机整数
        r(j) = vec(t);   % 取随机数
        vec(t)=[]; %从数组中删除当前元素,防止某个数再被选择
    end
end
end
