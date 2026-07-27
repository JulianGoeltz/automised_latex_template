import matplotlib.pyplot as plt
fig, ax = plt.subplots()
ax.plot([1, 2, 3], label='test')
ax.legend(frameon=False)
plt.savefig('test.png')


