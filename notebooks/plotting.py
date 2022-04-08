import matplotlib.pyplot as plt
def plot_vector(xy, uv, factor=4):
    x, y = xy[...,0],xy[...,1]
    u, v = uv[...,0],uv[...,1]
    x, y, u, v = map(lambda a:a.flat, [x,y,u,v])
    
    fig = plt.figure(figsize=plt.figaspect(1))
    plt.quiver(x, y, u, v)