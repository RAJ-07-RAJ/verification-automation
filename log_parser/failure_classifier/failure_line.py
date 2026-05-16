import re
import os

logs_folder = "sample_logs"
log_files   = sorted([f for f in os.listdir(logs_folder) if f.endswith(".log")])

def classify(line):
    if "Data mismatch" in line:
        return "DATA_MISMATCH"
    elif "ASSERTION FAILED" in line and "AWREADY" in line:
        return "ASSERTION_AWREADY"
    elif "ASSERTION FAILED" in line and "RVALID" in line:
        return "ASSERTION_RVALID"
    elif "ASSERTION FAILED" in line and "Reset" in line:
        return "ASSERTION_RESET"
    elif "ASSERTION FAILED" in line and "BVALID" in line:
        return "ASSERTION_BVALID"
    elif "timeout" in line.lower() and "ASSERTION" not in line:
        return "TIMEOUT"
    elif "Protocol violation" in line:
        return "PROTOCOL_VIOLATION"
    elif "Bus stall" in line:
        return "BUS_STALL"
    elif "UVM_FATAL" in line:
        return "FATAL_STOP"
    else:
        return None

for filename in log_files:
    filepath = os.path.join(logs_folder, filename)
    with open(filepath, "r") as f:
        for line in f:
            line = line.strip()
            fault_type = classify(line)
            if fault_type:
                print(f"{filename:<12}  {fault_type}")