# 此程序用于第一问的数值计算  请确保安装scipy包再运行

from scipy.optimize import fsolve

# 解方程求p
def equation(p):
    return 2 * (1 - p) * (1 - 2 * p) * (1 - p**33) - p * (1 - p) * (16 * (1 - 128 * p**7) * (1 - p) + (1 - 2 * p) * (1 - p**33) + 1024 * p**7 * (1 - p**26) * (1 - 2 * p))

result = fsolve(equation, 0.1)

print(f"p = {result[0]:.6f}")

# 计算参数
tao = result[0]
Ptr = 1 - ( 1 - tao )**2
Ps  = 2 * tao * ( 1 - tao ) / Ptr
E   = 1 / Ptr - 1
S   = 455.8 * Ps * 0.0000263273365511189 / (Ps * 0.000131453883282141 + E * 0.000009 + ( 1 - Ps ) * 0.000148453883282141)

print(f"S = {S:.6f}")
