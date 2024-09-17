import torch
import requests
import msgpack
import numpy as np

class GPUMarketplaceClient:
    def __init__(self, base_url):
        self.base_url = base_url

    def execute_operation(self, operation, input_data):
        url = f"{self.base_url}/api/ml/execute"
        payload = msgpack.packb({
            "operation": operation,
            "input_data": input_data
        })
        headers = {'Content-Type': 'application/msgpack'}
        response = requests.post(url, data=payload, headers=headers)
        if response.status_code == 200:
            result = msgpack.unpackb(response.content)['result']
            return torch.tensor(result, dtype=torch.float32)
        else:
            raise Exception(f"Error: {msgpack.unpackb(response.content)['error']}")

    def matrix_multiply(self, matrix_a, matrix_b):
        input_data = {
            "matrix_a": matrix_a.tolist(),
            "matrix_b": matrix_b.tolist()
        }
        return self.execute_operation("matrix_multiply", input_data)

# Usage example
if __name__ == "__main__":
    # Initialize the client
    client = GPUMarketplaceClient("http://localhost:4000")

    # Create some sample PyTorch tensors
    matrix_a = torch.rand(3, 4)
    matrix_b = torch.rand(4, 2)

    print("Matrix A:")
    print(matrix_a)
    print("\nMatrix B:")
    print(matrix_b)

    try:
        # Perform matrix multiplication using the GPU marketplace
        result = client.matrix_multiply(matrix_a, matrix_b)

        print("\nResult from GPU Marketplace:")
        print(result)

        # Verify the result with local PyTorch computation
        local_result = torch.matmul(matrix_a, matrix_b)
        print("\nLocal PyTorch result:")
        print(local_result)

        # Compare the results
        is_close = torch.allclose(result, local_result, atol=1e-6)
        print(f"\nResults are close: {is_close}")
    except Exception as e:
        print(f"An error occurred: {str(e)}")
