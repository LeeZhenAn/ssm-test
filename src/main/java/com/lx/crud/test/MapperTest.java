package com.lx.crud.test;

import com.lx.crud.bean.Department;
import com.lx.crud.bean.Employee;
import com.lx.crud.dao.DepartmentMapper;
import com.lx.crud.dao.EmployeeMapper;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

/**
 * 测试dao层的工作
 * 推荐spring的项目可以使用spring 的单元测试，可以自动注入我们需要的组件
 * 1.导入SpringTest模块
 * 2. @ContextConfiguartion 指定spring配置文件的位置
 * 3.直接autowired需要的组件即可
 */
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations = {"classpath:applicationContext.xml"})
public class MapperTest {

    @Autowired
    DepartmentMapper departmentMapper;

    @Autowired
    EmployeeMapper employeeMapper;

    /**
     * 测试DepartmentMapper
     */
    @Test
    public void testCRUD(){

        /*//1.创建springIOC容器
        ApplicationContext ioc = new ClassPathXmlApplicationContext("applicationContext.xml");
        //2.从容器中获取mapper
        DepartmentMapper bean = ioc.getBean(DepartmentMapper.class);*/
        System.out.println(departmentMapper);

        //1.插入几个部门
        //departmentMapper.insertSelective(new Department(null, "开发部"));
        //departmentMapper.insertSelective(new Department(null, "测试部"));

        //2.删除员工数据，测试员工插入
        //employeeMapper.insertSelective(new Employee(null, "Jerry", "M", "Jerry@163.com", 1));

        //3.批量插入多个员工;使用可以批量操作的sqlSession



    }

}
