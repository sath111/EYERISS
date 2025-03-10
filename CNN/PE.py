import numpy as np

class ProcessingElement:
    def __init__(self, data_bitwidth=16, addr_bitwidth=9, kernel_size=3, act_size=5):
        self.data_bitwidth = data_bitwidth
        self.addr_bitwidth = addr_bitwidth
        self.kernel_size = kernel_size
        self.act_size = act_size
        
        # Memory buffers
        self.weights = np.zeros((kernel_size, kernel_size), dtype=int)
        self.activations = np.zeros((act_size, act_size), dtype=int)
        self.psum = np.zeros((act_size - kernel_size + 1, act_size - kernel_size + 1), dtype=int)
        
        # Control signals
        self.load_done = False
        self.compute_done = False

    def load_weights(self, weights):
        """Load weights into memory."""
        assert weights.shape == (self.kernel_size, self.kernel_size)
        self.weights = weights.copy()
        self.load_done = True
        print("Weights Loaded:")
        print(self.weights)
    
    def load_activations(self, activations):
        """Load activations into memory."""
        assert activations.shape == (self.act_size, self.act_size)
        self.activations = activations.copy()
        self.load_done = True
        print("Activations Loaded:")
        print(self.activations)

    def compute(self):
        """Perform MAC operation for convolution."""
        if not self.load_done:
            print("Error: Data not loaded!")
            return
        
        for i in range(self.act_size - self.kernel_size + 1):
            for j in range(self.act_size - self.kernel_size + 1):
                region = self.activations[i:i+self.kernel_size, j:j+self.kernel_size]
                self.psum[i, j] = np.sum(region * self.weights)
        
        self.compute_done = True
        print("Computation Done. Output PSUM:")
        print(self.psum)

    def get_output(self):
        """Return the computed psum."""
        if self.compute_done:
            return self.psum
        else:
            print("Error: Computation not completed!")
            return None

# Example Usage
pe = ProcessingElement()
weights = np.array([[1, 0, -1], [1, 0, -1], [1, 0, -1]])
activations = np.array([
    [3, 1, 2, 1, 0],
    [0, 1, 3, 2, 1],
    [1, 0, 2, 1, 3],
    [2, 1, 0, 3, 2],
    [1, 2, 1, 0, 1]
])

pe.load_weights(weights)
pe.load_activations(activations)
pe.compute()
result = pe.get_output()