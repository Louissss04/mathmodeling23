%本程序用于计算问题1的仿真解 可以自行调整data_rate，cw_min，cw_max，max_retries，simulation_duration

clear all
% 模拟参数
payload_length = 1500 * 8; % 载荷长度，单位比特
phy_duration = 13.6e-6;    % PHY头时长，单位秒
mac_header = 30 * 8;       % MAC头长度，单位比特
data_rate = 455.8e6;       % 物理层速率，单位比特每秒
ack_duration = 32e-6;      % ACK时长，单位秒
sifs_duration = 16e-6;     % SIFS时长，单位秒
difs_duration = 43e-6;     % DIFS时长，单位秒
slot_duration = 9e-6;      % SLOT时长，单位秒
ack_timeout = 65e-6;       % ACK超时时长，单位秒
cw_min = 16;               % 最小竞争窗口
cw_max = 1024;             % 最大竞争窗口
max_retries = 32;          % 最大重传次数
cw = cw_min;               % 初始化CW
simulation_duration = 1000; % 模拟时间

% 进一步计算参数
mac_duration = mac_header / data_rate; % MAC时长
payload_duration = payload_length / data_rate; % E(P)时长
Ts = mac_duration + phy_duration + payload_duration + sifs_duration + ack_duration + difs_duration; % Ts时长
Tc = mac_duration + phy_duration + payload_duration + ack_timeout + difs_duration; % Tc时长

% 开始模拟
T = 0;  % 初始化时间
TTe = 0;
TTs = 0;
TTc = 0;
cw1 = randi([0, cw - 1]);  % 生成随机回退数cw1.cw2
cw2 = randi([0, cw - 1]);  
collision_count = 0; % 记录冲突次数

while T < simulation_duration  % 设置模拟的时间上限
    if cw1 == cw2
        % 发生碰撞
        if collision_count > max_retries  % 达到最大重试次数上限   
            collision_count = 0;  
            TTe = TTe + cw1 * slot_duration; 
            TTc = TTc + Tc; 
            T = T + Tc + cw1 * slot_duration;  % 更新时间
            collision_count = collision_count + 1;
            cw = min( 2^collision_count * cw_min , cw_max); % 调整竞争窗口大小，不超过cw_max
            cw1 = randi([0, cw - 1]);  % 重新生成随机回退数cw1
            cw2 = randi([0, cw - 1]);  % 重新生成随机回退数cw2
        else
        TTe = TTe + cw1 * slot_duration; 
        TTc = TTc + Tc; 
        T = T + Tc + cw1 * slot_duration;  % 更新时间
        collision_count = collision_count + 1; 
        cw = min(2^collision_count * cw_min , cw_max);  % 调整竞争窗口大小，不超过cw_max
            if collision_count > max_retries % 达到最大重试次数上限              
                cw = cw_min;
                cw1 = randi([0, cw - 1]);  % 重新生成随机回退数cw1
                cw2 = randi([0, cw - 1]);  % 重新生成随机回退数cw2
            else
                cw1 = randi([0, cw - 1]);  % 重新生成随机回退数cw1
                cw2 = randi([0, cw - 1]);  % 重新生成随机回退数cw2
            end    
        end
    else
        % 比较cw1和cw2的大小，确定哪一个进入信道
        if cw1 < cw2
            collision_count = 0;
            cw = cw_min;
            % cw1进入信道，cw2保持不变
            TTe = TTe + cw1 * slot_duration;
            TTs = TTs + Ts;
            T = T + Ts + cw1 * slot_duration;  % 更新时间
            cw2 = cw2 - cw1;
            cw1 = randi([0, cw - 1]);  % 重新生成随机回退数cw1
            
        else
            cw = cw_min;
            collision_count = 0;
            % cw2进入信道，cw1保持不变
            TTe = TTe + cw2 * slot_duration;
            TTs = TTs + Ts;
            T = T + Ts + cw2 * slot_duration;  % 更新时间
            cw1 = cw1 - cw2;
            cw2 = randi([0, cw - 1]);  % 重新生成随机回退数cw2
            
        end
    end
end

TP = payload_duration * TTs * data_rate / ( 10^6 * Ts * T );

% 输出结果
fprintf('T (总时长): %.6f 秒\n', T);
fprintf('TTe (空闲总时长): %.6f 秒\n', TTe);
fprintf('TTc (冲突总时长): %.6f 秒\n', TTc);
fprintf('TTs (成功传输总时长): %.6f 秒\n', TTs);
fprintf('吞吐量: %.6f Mbps\n', TP);
