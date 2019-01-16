package com.lx.crud.controller;

import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import com.lx.crud.bean.Employee;
import com.lx.crud.bean.Msg;
import com.lx.crud.servcie.EmployeeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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
     *
     * 后端校验标准：
     * 1.支持JSR303校验
     * 2.导入hibernate validator
     * @param employee
     * @return
     */
    @ResponseBody
    @RequestMapping(value = "/emps", method = RequestMethod.POST)
    public Msg saveEmp(@Valid Employee employee, BindingResult result){
        if (result.hasErrors()){
            Map<String, Object> map = new HashMap<>();
            //校验失败返回失败，在模态框中显示校验失败的错误信息
            List<FieldError> errors = result.getFieldErrors();
            for (FieldError error : errors) {
                System.out.println("错误的字段名："+error.getField());
                System.out.println("错误信息："+error.getDefaultMessage());
                map.put(error.getField(), error.getDefaultMessage());
            }
            return Msg.fail().add("errorFields", map);

        } else {
            employeeService.saveEmp(employee);
            return Msg.success();
        }

    }

    /**
     * 检验用户名是否合法
     * @param empName
     * @return
     */
    @ResponseBody
    @RequestMapping("/checkuser")
    public Msg checkuser(@RequestParam("empName") String empName){
        //判断用户名是否是合法的表达式
        String regName = "(^[a-zA-Z0-9_-]{6,16}$)|(^[\\u2E80-\\u9FFF]{2,5})";
        if (!empName.matches(regName)){
            return Msg.fail().add("va_msg", "用户名需要由2-5位中文组成或者6-16位英文组成!");
        }

        //数据库用户名重复校验
        boolean b = employeeService.checkUser(empName);
        if (b){
            return Msg.success();
        }
        return Msg.fail().add("va_msg", "用户名不可用!");
    }

    @ResponseBody
    @GetMapping("/emp/{id}")
    public Msg getEmp(@PathVariable("id") Integer id){

        Employee employee = employeeService.getEmp(id);
        return Msg.success().add("emp", employee);
    }

}
