%本程序用于计算问题4的仿真解，请将update_state.m文件与该文件放在同一个目录下 本程序注释较少 可以参考前三个程序的注释辅助理解

clear all
% 模拟参数
payload_length = 1500 * 8; % 载荷长度，单位比特
phy_duration = 13.6e-6;    % PHY头时长，单位秒
mac_header = 30 * 8;       % MAC头长度，单位比特
data_rate = 286.8e6;       % 物理层速率，单位比特每秒
ack_duration = 32e-6;      % ACK时长，单位秒
sifs_duration = 16e-6;     % SIFS时长，单位秒
difs_duration = 43e-6;     % DIFS时长，单位秒
slot_duration = 9e-6;      % SLOT时长，单位秒
ack_timeout = 65e-6;       % ACK超时时长，单位秒
cw_min = 16;               % 最小竞争窗口
cw_max = 1024;             % 最大竞争窗口
max_retries = 32;          % 最大重传次数
cw = cw_min;               % 初始化CW
simulation_duration = 1000;% 模拟时间
P = 0;                     % 丢包率

% 进一步计算参数
mac_duration = mac_header / data_rate; % MAC时长
payload_duration = payload_length / data_rate; %E(P)时长
Ts = mac_duration + phy_duration + payload_duration + sifs_duration + ack_duration + difs_duration;
Tc = mac_duration + phy_duration + payload_duration + ack_timeout + difs_duration;

% 初始化系统时间
T = 0;

CW(1) = cw_min;
CW(2) = cw_min;
CW(3) = cw_min;

cw1 = randi([0, CW(1) - 1]);
cw2 = randi([0, CW(2) - 1]);
cw3 = randi([0, CW(3) - 1]);

bo(1) = cw1;
bo(2) = cw2;
bo(3) = cw3;

rest(3) = 0;
TP(3) = 0;

% 初始化系统状态向量
system_state = update_state(bo(1),bo(2),bo(3),rest(1),rest(2),rest(3)); 
counter(3) = 0;
TTe(3) = 0;
TTs(3) = 0;
TTc(3) = 0;
TTw(3) = 0;

while T < simulation_duration
    
    % 在这里进行状态判断和决策，更新 system_state
    if isequal(system_state, [0, 0, 0])
        bo_min = min(min(bo(1), bo(2)), bo(3));
        T = T + bo_min * slot_duration;
        TTe(1) = TTe(1) + bo_min * slot_duration;
        TTe(2) = TTe(2) + bo_min * slot_duration;
        TTe(3) = TTe(3) + bo_min * slot_duration;
        bo = bo - bo_min;
        system_state = update_state(bo(1),bo(2),bo(3),rest(1),rest(2),rest(3));      
    elseif isequal(system_state, [1, -1, 0])
        if rest(1) == 0
            rest(1) = Ts;
        end
        if rest(1) >= bo(3) * slot_duration
            T = T + bo(3) * slot_duration;
            TTs(1) = TTs(1) + bo(3) * slot_duration;
            TTw(2) = TTw(2) + bo(3) * slot_duration;
            TTe(3) = TTe(3) + bo(3) * slot_duration;
            rest(1) = rest(1) - bo(3) * slot_duration;
            if rest(1) == 0
                counter(1) = 0;
                CW(1) = cw_min;
                bo(1) = randi([0, CW(1) - 1]);
            end
            bo(3) = 0;
            system_state = update_state(bo(1),bo(2),bo(3),rest(1),rest(2),rest(3)); 
        elseif rest(1) < bo(3) * slot_duration
            T = T + rest(1);
            TTs(1) = TTs(1) + rest(1);
            TTw(2) = TTw(2) + rest(1);
            TTe(3) = TTe(3) + rest(1);
            bo(3) = bo(3) - rest(1) / slot_duration;
            rest(1) = 0;
            counter(1) = 0;
            CW(1) = cw_min;
            bo(1) = randi([0, CW(1) - 1]); 
            system_state = update_state(bo(1),bo(2),bo(3),rest(1),rest(2),rest(3)); 
        end
    elseif isequal(system_state, [1, -1, 1])
        for i = 1:2:3
            if rest(i) == 0
                rest(i) = Ts;
            end
        end
        rest_min = min(min(rest(1), rest(3)), rest(3));
        T = T + rest_min;
        TTs(1) = TTs(1) + rest_min;
        TTw(2) = TTw(2) + rest_min;
        TTs(3) = TTs(3) + rest_min;
        rest(1) = rest(1) - rest_min;
        rest(3) = rest(3) - rest_min;
        for i = 1:2:3
            if rest(i) == 0
                counter(i) = 0;
                CW(i) = cw_min;
                bo(i) = randi([0, CW(i) - 1]);
            end
        end
        system_state = update_state(bo(1),bo(2),bo(3),rest(1),rest(2),rest(3)); 
    elseif isequal(system_state, [0, -1, 1])
        if rest(3) == 0
            rest(3) = Ts;
        end
        if rest(3) >= bo(1) * slot_duration
            T = T + bo(1) * slot_duration;
            TTs(3) = TTs(3) + bo(1) * slot_duration;
            TTw(2) = TTw(2) + bo(1) * slot_duration;
            TTe(1) = TTe(1) + bo(1) * slot_duration;
            rest(3) = rest(3) - bo(1) * slot_duration;
            if rest(3) == 0
                counter(3) = 0;
                CW(3) = cw_min;
                bo(3) = randi([0, CW(1) - 1]);
            end
            bo(1) = 0;
            system_state = update_state(bo(1),bo(2),bo(3),rest(1),rest(2),rest(3)); 
        elseif rest(3) < bo(1) * slot_duration
            T = T + rest(3);
            TTs(3) = TTs(3) + rest(3);
            TTw(2) = TTw(2) + rest(3);
            TTe(1) = TTe(1) + rest(3);
            bo(1) = bo(1) - rest(3) / slot_duration;
            rest(3) = 0;
            counter(3) = 0;
            CW(3) = cw_min;
            bo(3) = randi([0, CW(3) - 1]); 
            system_state = update_state(bo(1),bo(2),bo(3),rest(1),rest(2),rest(3)); 
        end
    elseif isequal(system_state, [-1, 1, -1])
        if rest(2) == 0
            rest(2) = Ts;
        end
        T = T + rest(2);
        TTw(1) = TTw(1) + rest(2);
        TTs(2) = TTs(2) + rest(2);
        TTw(3) = TTw(3) + rest(2);
        rest(2) = 0;
        counter(2) = 0;
        CW(2) = cw_min;
        bo(2) = randi([0, CW(2) - 1]);
        system_state = update_state(bo(1),bo(2),bo(3),rest(1),rest(2),rest(3)); 
    elseif isequal(system_state, [1, 1, 1])
        for i = 1:3
            rest(i) = Tc;
            counter(i) = counter(i) + 1;
        end
        T = T + Tc;
        TTc = TTc + Tc;
        rest = rest - Tc;
        for i = 1:3             
             CW(i) = min( 2^counter(i) * cw_min , cw_max);
             bo(i) = randi([0, CW(i) - 1]);
        end
        system_state = update_state(bo(1),bo(2),bo(3),rest(1),rest(2),rest(3));        
    elseif isequal(system_state, [1, 1, -1])
        for i = 1:2
            rest(i) = Tc;
            counter(i) = counter(i) + 1;
        end
        rest_min = 0;
        T = T + Tc;
        TTc(1) = TTc(1) + Tc;
        TTc(2) = TTc(2) + Tc;
        TTw(3) = TTw(3) + Tc;
        rest(1) = 0;
        rest(2) = 0;
        for i = 1:2
            CW(i) = min( 2^counter(i) * cw_min , cw_max);
            bo(i) = randi([0, CW(i) - 1]);
        end
        system_state = update_state(bo(1),bo(2),bo(3),rest(1),rest(2),rest(3)); 

    elseif isequal(system_state, [-1, 1, 1])
        for i = 2:3
            rest(i) = Tc;
            counter(i) = counter(i) + 1;
        end
        T = T + Tc;
        TTc(3) = TTc(3) + Tc;
        TTc(2) = TTc(2) + Tc;
        TTw(1) = TTw(1) + Tc;
        rest(3) = 0;
        rest(2) = 0;
        for i = 2:3
            CW(i) = min( 2^counter(i) * cw_min , cw_max);
            bo(i) = randi([0, CW(i) - 1]);
        end
        system_state = update_state(bo(1),bo(2),bo(3),rest(1),rest(2),rest(3)); 
    end
end

for i = 1:3
TP(i) = payload_duration * TTs(i) * data_rate / ( 10^6 * Ts * T );
fprintf('AP%d吞吐量: %.6f Mbps\n',i, TP(i));
end
fprintf('系统总吞吐量: %.6f Mbps\n', TP(1)+TP(2)+TP(3));

