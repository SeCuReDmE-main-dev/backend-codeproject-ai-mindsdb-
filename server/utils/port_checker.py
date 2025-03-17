import socket
import psutil
import logging
from typing import List, Dict, Optional

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def is_port_in_use(port: int, host: str = 'localhost') -> bool:
    """Check if a port is in use."""
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        try:
            s.bind((host, port))
            return False
        except socket.error:
            return True

def get_process_using_port(port: int) -> Optional[Dict]:
    """Get information about the process using a specific port."""
    for proc in psutil.process_iter(['pid', 'name', 'connections']):
        try:
            for conn in proc.connections():
                if conn.laddr.port == port:
                    return {
                        'pid': proc.pid,
                        'name': proc.name(),
                        'port': port
                    }
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            pass
    return None

def check_required_ports() -> Dict[str, Dict]:
    """Check all required ports for the application."""
    required_ports = {
        'PostgreSQL': 5432,
        'MongoDB': 27017,
        'MindsDB': 47337,
        'FastAPI': 8000,
        'CodeProject.AI': 32168
    }
    
    status = {}
    for service, port in required_ports.items():
        in_use = is_port_in_use(port)
        process_info = get_process_using_port(port) if in_use else None
        
        status[service] = {
            'port': port,
            'in_use': in_use,
            'process': process_info
        }
        
        if in_use:
            logger.info(f"{service} port {port} is in use by process {process_info['name']} (PID: {process_info['pid']})")
        else:
            logger.info(f"{service} port {port} is available")
    
    return status

def find_available_port(start_port: int, end_port: int = 65535) -> Optional[int]:
    """Find the next available port in a range."""
    for port in range(start_port, end_port + 1):
        if not is_port_in_use(port):
            return port
    return None

if __name__ == '__main__':
    print("Checking required ports...")
    port_status = check_required_ports()
    
    # Suggest alternative ports if needed
    for service, info in port_status.items():
        if info['in_use'] and service != 'PostgreSQL' and service != 'MongoDB':
            alt_port = find_available_port(info['port'] + 1)
            if alt_port:
                print(f"Alternative port for {service}: {alt_port}")