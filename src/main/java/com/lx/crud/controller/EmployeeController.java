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
import java.util.ArrayList;
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

    /**
     * 根据id查询员工
     * @param id
     * @return
     */
    @ResponseBody
    @GetMapping("/emp/{id}")
    public Msg getEmp(@PathVariable("id") Integer id){

        Employee employee = employeeService.getEmp(id);
        return Msg.success().add("emp", employee);
    }

    /**
     * 如果直接发送ajax=PUT请求
     * 封装的数据
     *  Employee{empId=1009, empName='null', gender='null', email='null', dId=null, department=null}
     * 员工更新的方法
     *
     * 问题：
     * 请求体中有数据，但是Employee对象封装不上；
     * update tbl_emp where emp_id = 1014;
     *
     * 原因：
     * Tomact:
     *  1.将请求体中的数据封装成一个amp
     *  2.request.getParameter("empName")就会从这个map中取值
     *  3.SpringMVC封装POJO对象的时候会把POJO中的每个属性的值，reuqest.getParameter("empName")
     *
     *  AJAX发送PUT请求发生的BUG:
     *      PUT请求，请求体中的数据：request.getParameter("empName")
     *      TOMCAT检测是PUT请求不会封装请求体中的数据为map,只有POST形式请求才封装请求体为map
     *
     *      org.apache.catalina.connector.Request--parseParameter() 3111
     *      protected String parseBodyMethods = "POST";
     * 	    if( !getConnector().isParseBodyMethod(getMethod()) ) {
     *                 success = true;
     *                 return;
     *      }
     *
     * 解决方案
     * 我们要能支持知己发送PUT之类的请求还有封装请求体中的数据
     * 1.配置上HttpPutFormContentFilter
     * 2.它的作用：将请求体中的数据解析包装成一个map
     * 3.request被重新包装,request.getParameter()被重写，就会从自己的map中取值
     * @param employee
     * @return
     */
    @ResponseBody
    @PutMapping("/emp/{empId}")
    public Msg saveEmp(Employee employee){
        employeeService.updateEmp(employee);
        return Msg.success();
    }

    //单个删除员工
   /* @ResponseBody
    @DeleteMapping("/emp/{id}")
    public Msg deleteEmpById(@PathVariable("id") Integer id){
        employeeService.deleteEmpById(id);
        return Msg.success();
    }*/

    /**
     * 单个批量二合一
     * 批量删除：1-2-3
     * 单个删除：1
     * @param id
     * @return
     */
    @ResponseBody
    @DeleteMapping("/emp/{ids}")
    public Msg deleteEmpById(@PathVariable("ids") String ids){
        //判断是否是多个删除格式
        if (ids.contains("-")){
            List<Integer> del_ids = new ArrayList<>();
            String[] str_ids = ids.split("-");
            for (String str_id : str_ids) {
                del_ids.add(Integer.parseInt(str_id));
            }
            employeeService.deleteBatch(del_ids);
        }else {
            Integer id = Integer.parseInt(ids);
            employeeService.deleteEmpById(id);
        }


        return Msg.success();
    }

}
