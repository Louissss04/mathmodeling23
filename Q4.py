# 此程序用于第四问的数值计算  请根据需要print出您想查看的变量
# 请自行调整参数r，m，W0，data_rate ,其中W0是CWmax，m 是log_2 (CWmax/CWmin)
# 此程序是考虑丢包率=0.1的情况 附件中另有一个Q3a.py是没有丢包率的情况 两者之间只差了两处  对应着正文修改的两处地方
# 请注意安装sympy 和 math 包
# 我们模拟的所有情况都是r>=m的 所以在定义b00的时候只定义了下面的情况
# 这个代码运行时间可能略长 但绝不是死循环 主要时间浪费在解方程上

from sympy import symbols, Eq, nsolve
import sympy
import math

# 符号变量
p1 = symbols('p1')
p2 = symbols('p2')
r = 32
m = 6
W0 = 16

# 模拟参数
payload_length = 1500 * 8  # 载荷长度，单位比特
phy_duration = 13.6e-6     # PHY头时长，单位秒
mac_header = 30 * 8        # MAC头长度，单位比特
data_rate = 455.8e6        # 物理层速率，单位比特每秒
ack_duration = 32e-6       # ACK时长，单位秒
sifs_duration = 16e-6      # SIFS时长，单位秒
difs_duration = 43e-6      # DIFS时长，单位秒
slot_duration = 9e-6       # SLOT时长，单位秒
ack_timeout = 65e-6        # ACK超时时长，单位秒

# 进一步计算参数
mac_duration = mac_header / data_rate # MAC时长
payload_duration = payload_length / data_rate # E(P)时长
Ts = mac_duration + phy_duration + payload_duration + sifs_duration + ack_duration + difs_duration
Tc = mac_duration + phy_duration + payload_duration + ack_timeout + difs_duration

# 计算 W_i
W = [2**i * W0 for i in range(m + 1)] + [2**m * W0 for i in range(m + 1, r + 1)]

# b00 表达式
b001 = 2 * (1 - p1) * (1 - 2 * p1) / (
    W0 * (1 - (2 * p1)**(m + 1)) * (1 - p1) +
    (1 - 2 * p1) * (1 - p1**(r + 1)) +
    W0 * 2**m * p1**(m + 1) * (1 - p1**(r - m)) * (1 - 2 * p1)
)

b002 = 2 * (1 - p2) * (1 - 2 * p2) / (
    W0 * (1 - (2 * p2)**(m + 1)) * (1 - p2) +
    (1 - 2 * p2) * (1 - p2**(r + 1)) +
    W0 * 2**m * p2**(m + 1) * (1 - p2**(r - m)) * (1 - 2 * p2)
)

# 初始化 b 矩阵
b1 = [[0] * W[i] for i in range(r + 1)]

# 计算第一列 b[i][0]
for i in range(r + 1):
    b1[i][0] = (p1**i) * b001

# 计算 b[i][k]
for i in range(r + 1):
    for k in range(1, W[i]):
        b1[i][k] = ((W[i] - k) / W[i]) * b1[i][0]

#初始化 b 矩阵
b2 = [[0] * W[i] for i in range(r + 1)]

# 计算第一列 b[i][0]
for i in range(r + 1):
    b2[i][0] = (p2**i) * b002

# 计算 b[i][k]
for i in range(r + 1):
    for k in range(1, W[i]):
        b2[i][k] = ((W[i] - k) / W[i]) * b2[i][0]

tao1 = 0
for i in range(r + 1):
    tao1 += b1[i][0]

tao2 = 0
for i in range(r + 1):
    tao2 += b2[i][0]

eq1 = Eq(p1 - tao2, 0)
eq2 = Eq(p2 - 1 + ( 1 - tao1 )**2 , 0)

variables = [p1, p2]
initial_guesses = [0.2, 0.3]

solution = nsolve([eq1, eq2], variables, initial_guesses)
print(solution)

tao2_value = tao2.subs(p2, solution[1]).evalf()
tao1_value = tao1.subs(p1, solution[0]).evalf()

Ptr = 1 - (1 - tao2_value) * ( 1 - tao1_value )**2
Ps1 = tao1_value * ( 1 - tao2_value ) / Ptr
Ps2 = tao2_value * ( 1 - tao1_value )**2 / Ptr

E1 = 1 / ( 1 - ( 1 - tao1_value ) * ( 1 - tao2_value )) - 1
E2 = 1 / Ptr - 1
S1 = 2*1e-6 * data_rate * Ps1 * payload_duration / ( E1 * slot_duration + Ps1 * Ts + ( 1 - Ps1 ) * Tc )
S2 = 1e-6 * data_rate * Ps2 * payload_duration / ( E2 * slot_duration + Ps2 * Ts + ( 1 - Ps2 ) * Tc )
S3 = S1

print(f"tao1 = {tao1_value:.6f}")
print(f"tao2 = {tao2_value:.6f}")
print(f"Ptr = {Ptr:.6f}")
print(f"E1 = {E1:.6f}次")
print(f"E2 = {E2:.6f}次")
print(f"Ps1 = {Ps1:.6f}")
print(f"Ps2 = {Ps2:.6f}")
print(f"AP1吞吐量S = {S1:.6f}Mbps")
print(f"AP2吞吐量S = {S2:.6f}Mbps")
print(f"AP3吞吐量S = {S3:.6f}Mbps")
print(f"总吞吐量S = {S1+S2+S3:.6f}Mbps")


