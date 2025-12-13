%% 测试1: 基本功能测试 - 验证概率分布
% function test_stochastic_policy_basic()
    % 测试基本功能：验证动作选择符合概率分布
    
    fprintf('=== 测试1: 基本功能测试 ===\n');
    
    % 设置测试参数
    x_length = 3;
    y_length = 3;
    state = [2, 2]; % 中心状态
    state_1d = x_length * (state(2)-1) + state(1);
    
    % 定义动作空间
    action_space = cell(9, 1);
    action_space{state_1d} = {'up', 'down', 'left', 'right'};
    
    % 定义策略概率
    policy = 1/4*ones(9, 4);
    % policy(state_1d, :) = [0.4, 0.3, 0.2, 0.1]; % 上、下、左、右的概率
    
    % 模拟多次选择
    num_trials = 10000;
    action_counts = containers.Map({'up', 'down', 'left', 'right'}, [0, 0, 0, 0]);
    
    for i = 1:num_trials
        action = stochastic_policy(state, action_space, policy, x_length, y_length);
        action_counts(action) = action_counts(action) + 1;
    end
    
    % 计算实际概率
    actual_probs = zeros(1, 4);
    actions = {'up', 'down', 'left', 'right'};
    for i = 1:4
        actual_probs(i) = action_counts(actions{i}) / num_trials;
    end
    
    % 显示结果
    fprintf('理论概率: [上:%.2f, 下:%.2f, 左:%.2f, 右:%.2f]\n', policy(state_1d, :));
    fprintf('实际概率: [上:%.4f, 下:%.4f, 左:%.4f, 右:%.4f]\n', actual_probs);
    
    % 计算误差
    error = abs(actual_probs - policy(state_1d, :));
    fprintf('最大误差: %.4f\n', max(error));
    
    % 可视化
    figure('Position', [100, 100, 800, 400]);
    
    subplot(1, 2, 1);
    bar(policy(state_1d, :));
    title('理论概率分布');
    ylabel('概率');
    xlabel('动作');
    set(gca, 'XTickLabel', actions);
    ylim([0, 0.5]);
    grid on;
    
    subplot(1, 2, 2);
    bar(actual_probs);
    title(sprintf('实际概率分布 (n=%d)', num_trials));
    ylabel('频率');
    xlabel('动作');
    set(gca, 'XTickLabel', actions);
    ylim([0, 0.5]);
    grid on;
    
    % 验证
    tolerance = 0.02; % 2%容忍度
    assert(max(error) < tolerance, '实际概率与理论概率差异过大!');
    fprintf('✓ 测试1通过!\n\n');
% end