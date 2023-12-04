# 此程序用于第三问的数值计算  请根据需要print出您想查看的变量
# 此程序是考虑丢包率=0的情况 附件中另有一个Q3.py是丢包率=0.1的情况 两者之间只差了两处  对应着正文修改的两处地方
# 请注意安装sympy 和 math 包
# 请自行调整参数r，m，W0，data_rate ,其中W0是CWmax，m 是log_2 (CWmax/CWmin)
# 这个代码运行时间可能略长 但绝不是死循环 主要时间浪费在解方程上
from sympy import symbols, Matrix, nsolve

import sympy
import math

# 符号变量
p = symbols('p')
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
payload_duration = payload_length / data_rate #E(P)时长
Ts = mac_duration + phy_duration + payload_duration + sifs_duration + ack_duration + difs_duration
Tc = mac_duration + phy_duration + payload_duration + ack_timeout + difs_duration
VP = mac_duration + phy_duration + payload_duration + sifs_duration + ack_duration

V = math.floor( VP / slot_duration) + 1 # 向上取整

# 计算 W_i
W = [2**i * W0 for i in range(m + 1)] + [2**m * W0 for i in range(m + 1, r + 1)]

# b00 表达式
b00 = 2 * (1 - p) * (1 - 2 * p) / (
    W0 * (1 - (2 * p)**(m + 1)) * (1 - p) +
    (1 - 2 * p) * (1 - p**(r + 1)) +
    W0 * 2**m * p**(m + 1) * (1 - p**(r - m)) * (1 - 2 * p)
)

# 初始化 b 矩阵
b = [[0] * W[i] for i in range(r + 1)]

# 计算第一列 b[i][0]
for i in range(r + 1):
    b[i][0] = (p**i) * b00

# 计算 b[i][k]
for i in range(r + 1):
    for k in range(1, W[i]):
        b[i][k] = ((W[i] - k) / W[i]) * b[i][0]

# 输出结果
#for i, row in enumerate(b):
#    for k, elem in enumerate(row):
#        print(f'b{i},{k} = {elem}')

#print(V)

# 将矩阵b的前V列加起来，但不超过Wi-1列
tao2 = 0
for i in range(r + 1):
    for k in range(min(V, W[i] )):
        tao2 += b[i][k]

tao1 = 0
for i in range(r + 1):
    tao1 += b[i][0]

# 方程
equation = tao2 - p

# 解方程
solutions = nsolve(equation, p, 0.3)

tao2_value = tao2.subs(p, solutions).evalf()
tao1_value = tao1.subs(p, solutions).evalf()

Ptr = 1 - ( 1 - tao1_value )**2
Ps = 2 * tao1_value * ( 1 - tao2_value ) / Ptr
E = 1 / tao1_value - 1
S = 1e-6 * data_rate * Ps * payload_duration / ( E * slot_duration + Ps * Ts + ( 1 - Ps ) * Tc )

print(f"p = {solutions:.6f}")
print(f"tao1 = {tao1_value:.6f}")
print(f"tao2 = {tao2_value:.6f}")
print(f"Ptr = {Ptr:.6f}")
print(f"Ps = {Ps:.6f}")
print(f"E = {E:.6f}")
print(f"吞吐量S = {S:.6f}")
# print(W)

