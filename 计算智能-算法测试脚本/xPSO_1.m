
function [gbestx,gbestfitness,gbesthistory]=xPSO_1(popsize,dimension,xmax,xmin,vmax,vmin,maxiter,FuncId)
%% xPSO算法： 缩放因子的粒子群优化算法

% popsize   ： 种群大小
% dimension ： 搜索维度
% xmax，xmin： 位置范围
% vman，vmin： 速度范围
% maxiter：    循环迭代次数
% maxrun ：    重复测试次数


Fitness = @SimpleBenchmark;


% 基本变量空间分配
x=rand(popsize,dimension);%分配存储空间+初始化
v=rand(popsize,dimension);%分配存储空间
fitness=ones(popsize,1).*realmax;  %分配存储空间fitne

% 局部最优空间分配
pbestx = rand(popsize,dimension);
pbestfitness = ones(popsize,1).*realmax;%向量操作

% 全局最优空间分配
gbestx=rand(1,dimension);
gbestfitness = realmax;%单值操作

gbesthistory=rand(maxiter,1); %记录每一代的最佳适应度数值,便于绘制收敛曲线


%% 【第一步】初始化粒子种群

 % 初始化粒子的位置和速度
for i=1:popsize
    x(i,:) = xmin+(xmax-xmin).*rand(1,dimension);
    v(i,:) = vmin+(vmax-vmin).*rand(1,dimension);     
end


%% 【第二步】 循环迭代寻找全局最优

c1=1.49445;
c2=1.49445;

for iter = 1: maxiter
    
   %% 第一步：更新局部最优和全局最优
    for i=1:popsize
        
        % 1.计算粒子的适应度(向量化操作)
        fitness(i)=Fitness(x(i,:),FuncId);
        
        % 2.更新粒子的局部最优位置
        if fitness(i)<= pbestfitness(i)
            pbestfitness(i)=fitness(i);
            pbestx(i,:) = x(i,:);
        end
        
        % 3. 更新粒子的全局最优位置
        if pbestfitness(i) <= gbestfitness
            gbestfitness = pbestfitness(i);
            gbestx(1,:) = pbestx(i,:);%向量赋值 
        end
    end
    
    
    %% 第二步： 更新位置向量和速度向量
    w=0.829;%根据缩放因子计算得到    
    for i =1:popsize
        %更新粒子的位置和速度（向量化操作）
        v(i,:)= w*v(i,:)+c1*rand*(pbestx(i,:)-x(i,:))+c2*rand*(gbestx(1,:) - x(i,:));
        x(i,:)= v(i,:)+x(i,:);
    end % end for
    
    %% 第三步： 越界判断（向量化操作）
    ox = x(i,:); ov=v(i,:);
    ox(ox>xmax)=xmax; ox(ox<xmin)=xmin;%或ox = min{ox,xmax},ox=max(ox,xmin);
    ov(ov>vmax)=vmax; ov(ov<vmin)=vmin;%或ov = min{ov,vmax},ov=max(ov,vmin);
    x(i,:)= ox; v(i,:)= ov;
   
    %% 第四步： 记录本代最佳适应度数值
    gbesthistory(iter)= gbestfitness;
    
        fprintf("函数F%d: xPSO_1算法,第%d代，最佳适应度 = %e\n",FuncId,iter,gbestfitness);
    
end %结束全部迭代

%disp(gbestx(:)');%输出全局最优解

