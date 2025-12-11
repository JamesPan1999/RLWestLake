%% MDP Toolbox 示例：森林管理问题
% 问题描述：森林状态（树木年龄）从1到Smax，每年选择砍伐或保护。
% 砍伐：立即获得收益，森林状态回到年龄1。
% 保护：森林年龄+1，但有一定概率发生火灾，使森林状态回到年龄1。

clear all; close all; clc;

%% 1. 定义问题参数
Smax = 5; % 最大森林年龄（状态数）
r1 = 0.1; % 年轻森林的收益（状态1）
r2 = 0.2; % 中年森林的收益
r3 = 0.8; % 成熟森林的收益（状态Smax）
p = 0.1; % 每年发生火灾的概率
discount = 0.95; % 折扣因子

%% 2. 构建MDP核心三要素
% 2.1 状态空间 S = {1, 2, ..., Smax}， 表示森林年龄
states = 1:Smax;

% 2.2 动作空间 A = {1: 保护, 2: 砍伐}
actions = 1:2;

% 2.3 构建转移概率矩阵 P 和奖励矩阵 R
% 工具箱要求 P 和 R 是 (S, A, S) 的三维数组
P = zeros(Smax, length(actions), Smax); % 转移概率
R = zeros(Smax, length(actions), Smax); % 即时奖励

for s = 1:Smax % 遍历当前状态
    for a = 1:length(actions) % 遍历动作
        if a == 1 % 动作1: 保护
            % 保护成功：森林年龄增长（除非已到最大年龄）
            s_next = min(s + 1, Smax);
            P(s, a, s_next) = 1 - p; % 无火灾的概率
            R(s, a, s_next) = eval(['r', num2str(s)]); % 根据年龄获得收益
            
            % 发生火灾：森林年龄重置为1
            P(s, a, 1) = p; % 火灾概率
            R(s, a, 1) = 0; % 火灾导致无收益
        else % 动作2: 砍伐
            % 砍伐后，森林年龄必定回到1
            P(s, a, 1) = 1.0;
            R(s, a, 1) = eval(['r', num2str(s)]); % 砍伐获得当前年龄对应的收益
        end
    end
end

%% 3. 使用MDP Toolbox求解
fprintf('=== 森林管理MDP问题求解 ===\n');
fprintf('状态数（最大森林年龄）: %d\n', Smax);
fprintf('火灾概率: %.2f, 折扣因子: %.2f\n\n', p, discount);

% 3.1 值迭代算法求解
[V, policy, iter, cpu_time] = mdp_value_iteration(P, R, discount);
fprintf('【值迭代算法结果】\n');
fprintf('迭代次数: %d, 计算时间: %.4f秒\n', iter, cpu_time);
fprintf('最优值函数 V: '); disp(V');
fprintf('最优策略 (1=保护，2=砍伐): '); disp(policy');

% 3.2 策略迭代算法验证
[policy_pi, V_pi] = mdp_policy_iteration(P, R, discount);
fprintf('\n【策略迭代算法验证】\n');
fprintf('最优策略: '); disp(policy_pi');
fprintf('值函数: '); disp(V_pi');

%% 4. 结果分析与简单可视化
% 4.1 打印最优策略解读
fprintf('\n=== 最优管理策略解读 ===\n');
for s = 1:Smax
    action_name = '保护';
    if policy(s) == 2
        action_name = '砍伐';
    end
    fprintf('当森林年龄为 %d 年时，最优动作是: %s\n', s, action_name);
end

% 4.2 绘制值函数和策略图
figure('Position', [100, 100, 900, 400])

% 子图1：最优值函数
subplot(1, 3, 1);
bar(1:Smax, V);
xlabel('森林状态（年龄）');
ylabel('最优长期价值 V(s)');
title('最优值函数');
grid on;

% 子图2：最优策略
subplot(1, 3, 2);
policy_plot = zeros(1, Smax);
for s = 1:Smax
    policy_plot(s) = policy(s) - 1; % 将1/2映射为0/1，便于绘图
end
stem(1:Smax, policy_plot, 'filled', 'LineWidth', 2);
ylim([-0.1, 1.1]);
yticks([0, 1]);
yticklabels({'保护', '砍伐'});
xlabel('森林状态（年龄）');
ylabel('最优动作');
title('最优策略');
grid on;

% 子图3：模拟未来10年的状态轨迹（从年龄1开始）
subplot(1, 3, 3);
current_state = 1;
state_history = zeros(1, 11);
state_history(1) = current_state;

for t = 1:10
    % 根据最优策略选择动作
    current_action = policy(current_state);
    
    % 根据转移概率随机转移到下一个状态
    prob_distribution = squeeze(P(current_state, current_action, :))';
    next_state = randsrc(1, 1, [1:Smax; prob_distribution]);
    
    state_history(t+1) = next_state;
    current_state = next_state;
end

plot(0:10, state_history, '-o', 'LineWidth', 1.5, 'MarkerSize', 8);
xlabel('时间（年）');
ylabel('森林年龄');
title('模拟状态轨迹（从年龄1开始）');
ylim([0.5, Smax+0.5]);
grid on;

sgtitle(['森林管理MDP最优解 (p=', num2str(p), ', \gamma=', num2str(discount), ')']);

%% 5. 访问核心数据（用于高级可视化）
fprintf('\n=== 用于自定义可视化的核心数据 ===\n');
% 5.1 查看状态s=3时，两个动作的完整转移概率和奖励
s = 3;
fprintf('\n状态 %d（%d年树龄）的详细模型数据：\n', s, s);
for a = 1:2
    action_name = '保护';
    if a == 2
        action_name = '砍伐';
    end
    fprintf('  动作【%s】:\n', action_name);
    fprintf('    转移概率分布: ');
    disp(squeeze(P(s, a, :))');
    fprintf('    对应即时奖励: ');
    disp(squeeze(R(s, a, :))');
end