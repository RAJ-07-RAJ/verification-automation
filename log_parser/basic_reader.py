input_file = "../sample_logs/sim1.log"

with open(input_file, "r") as f:
    for line in f:
        print(line.strip())