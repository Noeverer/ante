class Circle:
    def __init__(self, radius):
        self._radius = radius

    @property
    def radius(self):
        """radius属性的getter方法"""
        return self._radius

    @radius.setter
    def radius(self, value):
        """radius属性的setter方法，添加验证逻辑"""
        if value < 0:
            raise ValueError("半径不能为负数")
        self._radius = value

    @property
    def area(self):
        """计算圆的面积，这是一个只读属性"""
        import math
        return math.pi * self._radius ** 2

    @property
    def diameter(self):
        """计算圆的直径，这也是一个只读属性"""
        return 2 * self._radius


# 使用示例
if __name__ == "__main__":
    # 创建一个圆对象
    circle = Circle(5)
    
    # 像访问属性一样访问方法
    print(f"半径: {circle.radius}")
    print(f"直径: {circle.diameter}")
    print(f"面积: {circle.area}")
    
    # 修改半径
    circle.radius = 10
    print(f"新半径: {circle.radius}")
    print(f"新直径: {circle.diameter}")
    print(f"新面积: {circle.area}")
    
    # 尝试设置负数半径会抛出异常
    try:
        circle.radius = -5
    except ValueError as e:
        print(f"错误: {e}")