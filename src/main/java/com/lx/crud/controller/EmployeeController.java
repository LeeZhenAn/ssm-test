package com.lx.crud.controller;

import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import com.lx.crud.bean.Employee;
import com.lx.crud.bean.Msg;
import com.lx.crud.servcie.EmployeeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.List;

/**
 * 处理员工curd请求
 */
@Controller
public class EmployeeController {

    @Autowired
    EmployeeService employeeService;

    /**
     * 导入jackson包
     * @param pageNow
     * @return
     */
    @RequestMapping("/emps")
    @ResponseBody
    public Msg getEmpsWithJson(@RequestParam(value = "pn", defaultValue = "1") Integer pageNow){
        PageHelper.startPage(pageNow, 5);
        //startpage后面紧跟的一个查询就是一个分页查询
        List<Employee> emps = employeeService.getAll();
        //使用pageInfo包装查询后的结果,只需将pageInfo交给页码就行
        //封装了详细的分页信息，包括我们查询出来的数据,传入连续显示的页数
        PageInfo page = new PageInfo(emps, 5);
        return Msg.success().add("pageInfo", page);
    }

    /**
     * 查询员工数据(分页查询)
     * @return
     */
    //@RequestMapping("/emps")
    public String getEmps(@RequestParam(value = "pn", defaultValue = "1") Integer pageNow,
                          Model model){

        //这不是一个分页查询
        //引入PageHelper
        //在查询之前只需调用pageHelper,传入页码和每页大小
        PageHelper.startPage(pageNow, 5);
        //startpage后面紧跟的一个查询就是一个分页查询
        List<Employee> emps = employeeService.getAll();
        //使用pageInfo包装查询后的结果,只需将pageInfo交给页码就行
        //封装了详细的分页信息，包括我们查询出来的数据,传入连续显示的页数
        PageInfo page = new PageInfo(emps, 5);
        model.addAttribute("pageInfo",page);
        return "list";
    }

    /**
     * 员工保存
     * @param employee
     * @return
     */
    @ResponseBody
    @RequestMapping(value = "/emps", method = RequestMethod.POST)
    public Msg saveEmp(Employee employee){
        employeeService.saveEmp(employee);
        return Msg.success();
    }

    /**
     * 检验用户名是否合法
     * @param empName
     * @return
     */
    @ResponseBody
    @RequestMapping("/checkuser")
    public Msg checkuser(@RequestParam("empName") String empName){
        boolean b = employeeService.checkUser(empName);
        if (b){
            return Msg.success();
        }
        return Msg.fail();
    }


}
