%本程序用于计算问题3的仿真解 可以自行调整data_rate，cw_min，cw_max，max_retries，simulation_duration，P

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
max_retries = 32;           % 最大重传次数
simulation_duration = 1000;% 模拟时间
P = 0.1;                    % 丢包率

% 进一步计算参数
mac_duration = mac_header / data_rate; % MAC时长
payload_duration = payload_length / data_rate; %E(P)时长
Ts = mac_duration + phy_duration + payload_duration + sifs_duration + ack_duration + difs_duration;
Tc = mac_duration + phy_duration + payload_duration + ack_timeout + difs_duration;

% 初始化一些变量
CW1 = cw_min; % 初始CW
CW2 = cw_min;
T1 = 0; % 初始T1
T2 = 0; % 初始T2
T = 0; % 初始系统时间T
TTc = 0;
TTe = 0;
TTs = 0;
TTL = 0;
counter1 = 0;
counter2 = 0;
counters = 0;
counterc = 0;
counterl = 0;
% 生成随机回退数cw1和cw2
cw1 = randi([0, CW1 - 1]);
cw2 = randi([0, CW2 - 1]);

% 计算一次T1 T2
T1 = T1 + cw1 * slot_duration;
T2 = T2 + cw2 * slot_duration;
T1b = 0;
T2b = 0;

%T1b = T1;
%T2b = T2;

% 开始模拟
while T < simulation_duration
    if T1 <= T2
       if counter1 <= max_retries 
          if T2 - T1 >= Ts && T2b <= T1
            % 传输成功条件满足
             if rand() > P % 不丢包，成功
                counter1 = 0; 
                CW1 = cw_min; % 重置CW
                cw1 = randi([0, CW1 - 1]); % 生成随机回退数cw1
                T1b = T1 + Ts - difs_duration;
                T1  = T1b + cw1 * slot_duration + difs_duration;
                TTs = TTs + Ts;
                TTe = TTe + cw1 * slot_duration;
                counters = counters + 1;
                
             else  % 丢包，失败
                counter1 = counter1 + 1;
                CW1 = min(cw_max, cw_min * 2 ^ counter1); % 调整CW
                cw1 = randi([0, CW1 - 1]); % 生成随机回退数cw1
                T1b = T1 + Tc - difs_duration;
                T1 = T1b + cw1 * slot_duration + difs_duration;
                TTL = TTL + Tc;
                TTe = TTe + cw1 * slot_duration;
                counterl = counterl + 1;
               
             end   
          else
            % 传输成功条件不满足
                counter1 = counter1 + 1;
                CW1 = min(cw_max, cw_min * 2 ^ counter1); % 调整CW
                cw1 = randi([0, CW1 - 1]); % 生成随机回退数cw1
                T1b = T1 + Tc - difs_duration;
                T1 = T1b + cw1 * slot_duration + difs_duration;
                TTc = TTc + Tc;
                TTe = TTe + cw1 * slot_duration;
                counterc = counterc + 1;
               
          end    
       else  % 已经达到重传最大次数
          if T2 - T1 >= Ts && T2b <= T1
            % 传输成功条件满足
             if rand() > P % 不丢包，成功
                counter1 = 0;
                CW1 = cw_min; % 重置CW
                cw1 = randi([0, CW1 - 1]); % 生成随机回退数cw1
                T1b = T1 + Ts - difs_duration;
                T1  = T1b + cw1 * slot_duration + difs_duration;
                TTs = TTs + Ts;
                TTe = TTe + cw1 * slot_duration;
                counters = counters + 1;
               
             else  % 丢包，失败
                counter1 = 0;
                CW1 = cw_min; % 调整CW
                cw1 = randi([0, CW1 - 1]); % 生成随机回退数cw1
                T1b = T1 + Tc - difs_duration;
                T1 = T1b + cw1 * slot_duration + difs_duration;
                TTL = TTL + Tc;
                TTe = TTe + cw1 * slot_duration;
                counterl = counterl + 1;
                counter1 = counter1 + 1;

             end   
          else
            % 传输条件不满足，一定失败
                counter1 = 0;
                CW1 = cw_min; % 调整CW
                cw1 = randi([0, CW1 - 1]); % 生成随机回退数cw1
                T1b = T1 + Tc - difs_duration;
                T1 = T1b + cw1 * slot_duration +difs_duration;
                TTc = TTc + Tc;
                TTe = TTe + cw1 * slot_duration;
                counterc = counterc + 1;
                counter1 = counter1 + 1;
          end    
       end

    % 更新系统时间
    T = min(T1, T2);

    elseif T2 < T1
       if counter2 <= max_retries 
        if T1 - T2 >= Ts && T1b <= T2 
            % 传输成功条件满足
            if rand() > P % 不丢包，成功
                counter2 = 0; 
                CW2 = cw_min; % 重置CW
                cw2 = randi([0, CW2 - 1]); % 生成随机回退数cw2
                T2b = T2 + Ts - difs_duration;
                T2  = T2b + cw2 * slot_duration + difs_duration;
                TTs = TTs + Ts;
                TTe = TTe + cw2 * slot_duration;
                counters = counters + 1;
                
            else  % 丢包，失败
                counter2 = counter2 + 1;
                CW2 = min(cw_max, cw_min * 2 ^ counter2); % 调整CW
                cw2 = randi([0, CW2 - 1]); % 生成随机回退数cw2
                T2b = T2 + Tc - difs_duration;
                T2 = T2b + cw2 * slot_duration + difs_duration;
                TTL = TTL + Tc;
                TTe = TTe + cw2 * slot_duration;
                counterl = counterl + 1;
                
            end    
        else
            % 传输失败
                counter2 = counter2 + 1;
                CW2 = min(cw_max, cw_min * 2 ^ counter2 ); % 调整CW
                cw2 = randi([0, CW2 - 1]); % 生成随机回退数cw2
                T2b = T2 + Tc - difs_duration;
                T2 = T2b + cw2 * slot_duration + difs_duration;
                TTc = TTc + Tc;
                TTe = TTe + cw2 * slot_duration;
                counterc = counterc + 1;
                
        end
       else % 到达最大重传次数
        if T1 - T2 >= Ts && T1b <= T2 
            % 传输成功条件满足
            if rand() > P % 不丢包，成功
                counter2 = 0;
                CW2 = cw_min; % 重置CW
                cw2 = randi([0, CW2 - 1]); % 生成随机回退数cw2
                T2b = T2 + Ts - difs_duration;
                T2  = T2b + cw2 * slot_duration + difs_duration;
                TTs = TTs + Ts;
                TTe = TTe + cw2 * slot_duration;
                counters = counters + 1;
                
            else  % 丢包，失败
                counter2 = 0;
                
                CW2 = cw_min; % 调整CW
                cw2 = randi([0, CW2 - 1]); % 生成随机回退数cw2
                T2b = T2 + Tc - difs_duration;
                T2 = T2b + cw2 * slot_duration + difs_duration;
                TTL = TTL + Tc;
                TTe = TTe + cw2 * slot_duration;
                counterl = counterl + 1;
                counter2 = counter2 + 1;
            end    
        else
            % 传输失败
                counter2 = 0;
                
                CW2 = cw_min; % 调整CW
                cw2 = randi([0, CW2 - 1]); % 生成随机回退数cw2
                T2b = T2 + Tc - difs_duration;
                T2 = T2b + cw2 * slot_duration + difs_duration;
                TTc = TTc + Tc;
                TTe = TTe + cw2 * slot_duration;
                counterc = counterc + 1;
                counter2 = counter2 + 1;
        end  
       end 
      
    % 更新系统时间
    T = min(T1, T2);

    end
end

TP = payload_duration * TTs * data_rate / ( 10^6 * Ts * (T1 + T2) );

% 输出结果
fprintf('T (总时长): %.6f 秒\n', T);
fprintf('T‘ (累计总时长): %.6f 秒\n', T1 + T2);
fprintf('TTe (空闲总时长): %.6f 秒\n', TTe);
fprintf('TTc (冲突总时长): %.6f 秒\n', TTc);
fprintf('TTs (成功传输总时长): %.6f 秒\n', TTs);
fprintf('TTL(丢包浪费总时长): %.6f 秒\n', TTL);
fprintf('空闲间隙个数: %.6f 个\n', TTe / slot_duration);
fprintf('ctc (冲突次数): %d 次\n', counterc);
fprintf('cts (成功次数): %d 次\n', counters);
fprintf('ctl (丢包次数): %d 次\n', counterl);
fprintf('吞吐量: %.6f Mbps\n', TP);