x = "x_value.txt"
y = "y_value.txt"

def binary_to_decimal(binary_num : str):
    res = 0
    for i,digit in enumerate(binary_num):
        res += int(digit) * (1<<(len(binary_num)-i - 1))
    return res

def read_num(raw_num : str):
    raw_num = raw_num.strip()
    
    if len(raw_num)  != 21 :
        raise "invalid number entered"
    
    intiger_part = binary_to_decimal(raw_num[:10])
    fraction_part = binary_to_decimal(raw_num[11:])
    
    return intiger_part + (fraction_part/(1<<10))
    
def read_vector_file(file_address : str):
    resualt_vector = []

    with open(file_address, 'r') as file_reader:
        for line in file_reader:
            if line == '':
                break
            resualt_vector.append(read_num(line))
            
    return resualt_vector
    
x_vector = read_vector_file(x)
y_vector = read_vector_file(y)

def get_mean(vector : list):
    sum = 0
    for element in vector:
        sum += element
        
    return sum / len(vector)

x_mean = get_mean(x_vector)
y_mean = get_mean(y_vector)

ss_xx = 0
ss_xy = 0

for x_i,y_i in zip(x_vector, y_vector):
    x_minus_mean = x_i - x_mean
    y_minus_mean = y_i - y_mean
    
    ss_xx += x_minus_mean * x_minus_mean
    ss_xy += x_minus_mean * y_minus_mean
    
b_1 = ss_xy / ss_xx
b_0 = y_mean - x_mean * b_1

def to_bin(dec_num:int):
    res = ""
    
    one_digit = 0
    reminder = dec_num
    
    for i in range(21):
        one_digit = int(reminder % 2)
        reminder  = reminder // 2
        res += str(one_digit)

    return res[::-1]

        
def decimal_to_binay_fix_point(number):
    res = int((number)*(2**10))
    return to_bin(res)

print(f"ss_xx is {decimal_to_binay_fix_point(ss_xx)} ss_xy is {decimal_to_binay_fix_point(ss_xy)}")
print(f"ss_xx is {ss_xx} ss_xy is {ss_xy}")
print(f"b_1 is {b_1} b_0 is {b_0}")
print(f"binary_form : b_1 is {decimal_to_binay_fix_point(b_1)} b_0 is {decimal_to_binay_fix_point(b_0)}")

print("errors:\n")

for x_i,y_i in zip(x_vector, y_vector):
    print(f"error {x_i}, {y_i} is : {y_i - b_0 - (b_1 * x_i)}")

