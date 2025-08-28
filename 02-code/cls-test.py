class Person:
    species = "Homo sapiens"
    
    def __init__(self, name, age):
        self.name = name
        self.age = age
    
    @classmethod
    def get_species(cls):
        # cls指向Person类本身
        return cls.species
    
    @classmethod
    def create_baby(cls, name):
        # cls指向Person类，可以用来创建实例
        return cls(name, 0)  # 等同于Person(name, 0)
    
    @classmethod
    def from_string(cls, person_str):
        # 使用cls创建类实例的工厂方法
        name, age = person_str.split('-')
        return cls(name, int(age))

# 使用示例
print(Person.get_species())  # 输出: Homo sapiens

baby = Person.create_baby("Alice")
print(baby.name, baby.age)  # 输出: Alice 0

person = Person.from_string("Bob-25")
print(person.name, person.age)  # 输出: Bob 25