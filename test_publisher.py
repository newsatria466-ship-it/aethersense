#!/usr/bin/env python3
"""
AetherSense — Smart City IoT Telemetry Simulator
Mengirimkan telemetry ESP32 realistis ke broker HiveMQ
Broker: broker.hivemq.com (Port 1883)
Topik : aethersense/ESP32-001/telemetry
"""

import socket
import struct
import json
import time
import random
import sys

BROKER = "broker.hivemq.com"
PORT = 1883
DEVICE_ID = "ESP32-001"
TOPIC = f"aethersense/{DEVICE_ID}/telemetry"

def encode_string(s):
    b = s.encode('utf-8')
    return struct.pack('!H', len(b)) + b

def encode_varlen(length):
    buf = bytearray()
    while True:
        digit = length % 128
        length //= 128
        if length > 0:
            digit |= 0x80
        buf.append(digit)
        if length == 0:
            break
    return bytes(buf)

class SimpleMqttClient:
    def __init__(self, host, port=1883, client_id=None):
        self.host = host
        self.port = port
        self.client_id = client_id or f"AetherSim-{random.randint(1000, 9999)}"
        self.sock = None

    def connect(self):
        self.sock = socket.create_connection((self.host, self.port), timeout=10)
        var_header = b'\x00\x04MQTT\x04\x02\x00\x3c'
        payload = encode_string(self.client_id)
        remaining = var_header + payload
        packet = b'\x10' + encode_varlen(len(remaining)) + remaining
        self.sock.sendall(packet)
        resp = self.sock.recv(4)
        if len(resp) >= 4 and resp[3] == 0:
            return True
        return False

    def publish(self, topic, message_str):
        msg_bytes = message_str.encode('utf-8')
        remaining = encode_string(topic) + msg_bytes
        packet = b'\x30' + encode_varlen(len(remaining)) + remaining
        self.sock.sendall(packet)

    def close(self):
        if self.sock:
            try:
                self.sock.sendall(b'\xe0\x00')
                self.sock.close()
            except Exception:
                pass

if __name__ == "__main__":
    print("=====================================================")
    print("  🌐 AETHERSENSE — ESP32 TELEMETRY SIMULATOR")
    print(f"  Target Broker : {BROKER}:{PORT}")
    print(f"  Device ID     : {DEVICE_ID}")
    print(f"  Topik Target  : {TOPIC}")
    print("=====================================================")

    try:
        client = SimpleMqttClient(BROKER, PORT)
        print("Menghubungkan ke broker HiveMQ...")
        if client.connect():
            print(" Berhasil terhubung ke Broker!")
            print("Mengirim paket telemetry setiap 3 detik... (Tekan Ctrl+C untuk berhenti)\n")
        else:
            print("❌ Gagal terhubung ke broker.")
            sys.exit(1)

        seq = 0
        start_time = time.time()

        while True:
            seq += 1
            uptime_s = int(time.time() - start_time) + 420  # simulasi uptime ~7 menit

            # Skenario banjir setiap 4 paket sekali untuk pengujian alarm
            is_flood_test = (seq % 4 == 0)

            if is_flood_test:
                water_dist = round(random.uniform(5.0, 9.5), 1)
                water_lvl = round(random.uniform(75.0, 92.0), 1)
                flood_status = "Bahaya Banjir"
                is_flood_warning = True
                rain_status = "Hujan Sangat Lebat"
                rain_raw = random.randint(400, 750)
                is_raining = True
            else:
                water_dist = round(random.uniform(35.0, 50.0), 1)
                water_lvl = round(random.uniform(12.0, 24.0), 1)
                flood_status = "Aman"
                is_flood_warning = False
                rain_status = "Tidak Hujan"
                rain_raw = random.randint(3200, 3900)
                is_raining = False

            temp = round(random.uniform(27.5, 31.0), 1)
            hum = round(random.uniform(68.0, 84.0), 1)
            mq_raw = random.randint(95, 140)
            mq_adc = random.randint(450, 700)
            mq_sensor = round(random.uniform(120.0, 185.0), 1)
            air_status = "Normal / Baik"
            is_gas_polluted = False
            rssi = random.randint(-65, -52)

            payload = {
                "device_id": DEVICE_ID,
                "sequence": seq,
                "timestamp": int(time.time()),
                "uptime_s": uptime_s,
                "temperature_c": temp,
                "humidity_percent": hum,
                "mq135_raw": mq_raw,
                "mq135_adc_mv": mq_adc,
                "mq135_sensor_mv": mq_sensor,
                "air_quality_status": air_status,
                "is_gas_polluted": is_gas_polluted,
                "rain_raw": rain_raw,
                "rain_status": rain_status,
                "is_raining": is_raining,
                "water_distance_cm": water_dist,
                "water_level_cm": water_lvl,
                "flood_status": flood_status,
                "is_flood_warning": is_flood_warning,
                "wifi_rssi_dbm": rssi,
                "ldr_raw": 1250,
                "ambient_light": "Terang",
                "is_dark": False,
                "lighting_mode": "auto",
                "relay1": False,
                "relay2": False,
                "relay3": False,
                "relay4": False,
                "parking_total_slots": 10,
                "parking_occupied_slots": 3,
                "parking_available_slots": 7,
                "is_parking_full": False,
                "entry_gate_open": False,
                "exit_gate_open": False,
                "ir_entry_detected": False,
                "ir_exit_detected": False
            }

            json_str = json.dumps(payload)
            client.publish(TOPIC, json_str)

            alert_tag = "🚨 [FLOOD WARNING]" if is_flood_warning else "🟢 [NORMAL]"
            print(f"[{seq}] {alert_tag} Water: {water_lvl} cm ({flood_status}) | Temp: {temp}°C | RSSI: {rssi}dBm")
            time.sleep(3)

    except KeyboardInterrupt:
        print("\nSimulator dihentikan.")
        client.close()
    except Exception as e:
        print(f"\nTerjadi kesalahan: {e}")
