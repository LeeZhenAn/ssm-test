<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<html>
<head>
    <title>员工列表</title>
    <%--
        WEB路径：
        不以/开始的相对路径，找资源，以当前资源的路径为基准，经常容易出现问题
        以/开始的相对路径，找资源，以服务器的路径为标准(http://localhost:3306):需要加上项目名
    --%>
    <script src="${pageContext.request.contextPath }/static/js/jquery-3.3.1.min.js"></script>
    <!-- Bootstrap -->
    <link href="${pageContext.request.contextPath }/static/bootstrap/bootstrap-3.3.7-dist/css/bootstrap.min.css"
          rel="stylesheet">
    <!-- 加载 Bootstrap 的所有 JavaScript 插件。你也可以根据需要只加载单个插件。 -->
    <script src="${pageContext.request.contextPath }/static/bootstrap/bootstrap-3.3.7-dist/js/bootstrap.min.js"></script>
    <script>
        //定义一个全局变量保存总记录数
        var totalRecord, currentPage;

        //1.页面加载完成以后，直接去发送一个ajax请求，要到分页数据
        $(function () {
            //去首页
            to_page(1);
        });

        function build_emps_table(result) {
            //清空已存在的表格数据
            $("#emps_table tbody").empty();
            var emps = result.extend.pageInfo.list;
            $.each(emps, function (index, item) {
                var checkBoxTd = $("<td><input type='checkbox' class='check_item'/></td>");
                var empIdTd = $("<td></td>").append(item.empId);
                var empNameTd = $("<td></td>").append(item.empName);
                var genderTd = $("<td></td>").append(item.gender == 'M' ? "男" : "女");
                var emailTd = $("<td></td>").append(item.email);
                var deptNameTd = $("<td></td>").append(item.department.deptName);
                /**
                 *  <button class="btn btn-primary btn-sm">
                 <span class="glyphicon glyphicon-pencil" aria-hidden="true"></span>
                 编辑
                 </button>

                 <button class="btn btn-danger btn-sm">
                 <span class="glyphicon glyphicon-trash" aria-hidden="true"></span>
                 删除
                 </button>
                 */
                var editBtn = $("<button></button>").addClass("btn btn-primary btn-sm edit_btn")
                    .append($("<span></span>").addClass("glyphicon glyphicon-pencil")).append("编辑");

                //为编辑按钮添加一个自定义的属性，来表示当前员工id
                editBtn.attr("edit-id", item.empId);


                var delBtn = $("<button></button>").addClass("btn btn-danger btn-sm delete_btn")
                    .append($("<span></span>").addClass("glyphicon glyphicon-trash")).append("删除");

                //为输出按钮添加一个自定义的属性，来表示当前员工id
                delBtn.attr("del-id", item.empId);

                var btnTd = $("<td></td>").append(editBtn).append(" ").append(delBtn);
                //append方法执行完成以后还是返回原来的元素
                $("<tr></tr>").append(checkBoxTd)
                    .append(empIdTd)
                    .append(empNameTd)
                    .append(genderTd)
                    .append(emailTd)
                    .append(deptNameTd)
                    .append(btnTd)
                    .appendTo("#emps_table tbody");

            });
        }

        //解析显示分页信息
        function build_page_info(result) {
            $("#page_info_area").empty();
            $("#page_info_area").append("当前"
                + result.extend.pageInfo.pageNum
                + "页，总"
                + result.extend.pageInfo.pages
                + "页，总"
                + result.extend.pageInfo.total
                + "条记录");
            totalRecord = result.extend.pageInfo.total;
            currentPage = result.extend.pageInfo.pageNum;
        }

        //解析显示分页条，点击分页能去下一页...
        function build_page_nav(result) {
            //page_nav_area
            $("#page_nav_area").empty();
            var ul = $("<ul></ul>").addClass("pagination");
            var firstPageLi = $("<li></li>").append($("<a></a>").append("首页").attr("href", "#"));
            var prePageLi = $("<li></li>").append($("<a></a>").append("&laquo;"));
            //判断是否有前一页
            if (result.extend.pageInfo.hasPreviousPage == false) {
                firstPageLi.addClass("disabled");
                prePageLi.addClass("disabled");
            } else {
                //为元素添加点击翻页的事件
                firstPageLi.click(function () {
                    to_page(1);
                });
                prePageLi.click(function () {
                    to_page(result.extend.pageInfo.pageNum - 1);
                });
            }


            var nextPageLi = $("<li></li>").append($("<a></a>").append("&raquo;"));
            var lastPageLi = $("<li></li>").append($("<a></a>").append("末页").attr("href", "#"));
            //判断是否有后一页
            if (result.extend.pageInfo.hasNextPage == false) {
                nextPageLi.addClass("disabled");
                lastPageLi.addClass("disabled");
            } else {
                //为元素添加点击翻页的事件
                nextPageLi.click(function () {
                    to_page(result.extend.pageInfo.pageNum + 1);
                });
                lastPageLi.click(function () {
                    to_page(result.extend.pageInfo.pages);
                });
            }


            //添加首页和前一页的提示
            ul.append(firstPageLi).append(prePageLi);
            //item 1,2,3,4,5 遍历给ul中添加页码提示
            $.each(result.extend.pageInfo.navigatepageNums, function (index, item) {
                var numLi = $("<li></li>").append($("<a></a>").append(item));
                //判断点击的是否是当前页码
                if (result.extend.pageInfo.pageNum == item) {
                    numLi.addClass("active");
                }
                //当li点击后发送ajax请求，由于是ajax请求，因此每次点击事件前应清空数据
                numLi.click(function () {
                    to_page(item);
                });

                ul.append(numLi);
            });
            //添加下一页和末页的提示
            ul.append(nextPageLi).append(lastPageLi);

            //把ul加入nav
            var navEle = $("<nav></nav>").append(ul);
            navEle.appendTo("#page_nav_area");
        }

        //点击页数跳转
        function to_page(pn) {
            $.ajax({
                url: "${pageContext.request.contextPath }/emps",
                data: "pn=" + pn,
                type: "GET",
                success: function (result) {
                    //console.log(result);
                    //1.解析并显示员工数据
                    build_emps_table(result);
                    //2.解析并显示分页信息
                    build_page_info(result);
                    //3.解析并显示分页条数据
                    build_page_nav(result);
                }
            });
        }

    </script>
    <script>
        //编辑按钮逻辑
        //点击新增按钮弹出模态框
        $(function () {
            $("#emp_add_modal_btn").click(function () {
                //清除表单数据(表单重置)[dom对象方法，在jquery取出属性后加[0]]
                //表单完整重置(表单的数据，表单的样式)
                // $("#empAddModal form")[0].reset();
                rest_form("#empAddModal form");

                //发送ajax请求，查出部门信息，显示在下拉列表中
                getDepts("#empAddModal select");

                //弹出模态框
                $("#empAddModal").modal({
                    backdrop: "static"
                });
            });

            //保存信息
            $("#emp_save_btn").click(function () {
                //1.模态框中填写的表单数据提交给服务器进行保存
                //2.先将要提交给服务器的数据进行校验
                if (!validate_add_form()) {
                    return false;
                }
                //3.判断之前的ajax用户名校验是否成功，如果成功
                if ($(this).attr("ajax-va") == "error") {
                    show_validate_msg("#empName_add_input", "error", "用户名需要由2-5位中文组成或者6-16位英文组成!");
                    return false;
                }
                //2.发送ajax请求保存成功
                $.ajax({
                    url: "${pageContext.request.contextPath }/emps",
                    type: "POST",
                    data: $("#empAddModal form").serialize(),
                    success: function (result) {
                        if (result.code == 100) {
                            //alert(result.msg);
                            //员工保存成功:
                            //1.关闭模态框
                            $("#empAddModal").modal("hide");
                            //2.来到最后一页，显示刚才保存的数据
                            //发送ajax请求显示最后一页即可
                            to_page(totalRecord);
                        } else {
                            //显示失败信息
                            //console.log(result);
                            //有哪个字段的错误信息就显示哪个字段的
                            if (undefined != result.extend.errorFields.email) {
                                //显示邮箱错误信息
                                show_validate_msg("#email_add_input", "error", "邮箱格式不正确!");
                            }
                            if (undefined != result.extend.errorFields.empName) {
                                //显示员工名字的错误信息
                                show_validate_msg("#empName_add_input", "error", "用户名需要由2-5位中文组成或者6-16位英文组成!");
                            }
                        }


                    }

                });
            });

            //检测姓名是否重复
            $("#empName_add_input").change(function () {
                var empName = this.value;
                //发送ajax请求,校验用户名是否可用
                $.ajax({
                    url: "${pageContext.request.contextPath }/checkuser",
                    data: "empName=" + empName,
                    type: "POST",
                    success: function (result) {
                        if (result.code == 100) {
                            show_validate_msg("#empName_add_input", "success", "用户名可用");
                            $("#emp_save_btn").attr("ajax-va", "success");
                        } else {
                            show_validate_msg("#empName_add_input", "error", result.extend.va_msg);
                            $("#emp_save_btn").attr("ajax-va", "error");
                        }
                    }
                });
            });

        });

        //表单完整重置方法
        function rest_form(ele) {
            $(ele)[0].reset();
            //清空表单样式
            $(ele).find("*").removeClass("has-error has-success");
            $(ele).find(".help-block").text("");
        }

        //校验表单数据的方法
        function validate_add_form() {
            //1.拿到要校验的数据，使用正则表达式
            var empName = $("#empName_add_input").val();
            var regName = /(^[a-zA-Z0-9_-]{6,16}$)|(^[\u2E80-\u9FFF]{2,5})/;
            if (!regName.test(empName)) {
                //alert("用户名需要由2-5位中文组成或者6-16位英文组成!");
                show_validate_msg("#empName_add_input", "error", "用户名需要由2-5位中文组成或者6-16位英文组成!");

                return false;
            } else {
                show_validate_msg("#empName_add_input", "success", "");
            }

            //2.校验邮箱信息
            if (!validate_email("#email_add_input")) {
                return false;
            }

            return true;
        }

        function validate_email(ele) {
            var email = $(ele).val();
            var regEmail = /^([a-z0-9_\.-]+)@([\da-z\.-]+)\.([a-z\.]{2,6})$/;
            if (!regEmail.test(email)) {
                //alert("邮箱格式不正确!");
                show_validate_msg(ele, "error", "邮箱格式不正确!");
                return false;
            } else {
                show_validate_msg(ele, "success", "");
                return true;
            }

        }

        //校验方法相同，抽取出一个函数
        function show_validate_msg(ele, status, msg) {
            //清除当前元素校验状态
            $(ele).parent().removeClass("has-success has-error");
            $(ele).next("span").text("");
            if ("success" == status) {
                $(ele).parent().addClass("has-success");
                $(ele).next("span").text(msg);
            } else if ("error" == status) {
                $(ele).parent().addClass("has-error");
                $(ele).next("span").text(msg);
            }
        }

        //查出所有的部门信息并显示在下拉列表中
        function getDepts(ele) {
            //清空下拉列表的值
            $(ele).empty();
            $.ajax({
                url: "${pageContext.request.contextPath }/depts",
                type: "GET",
                success: function (result) {
                    //{depts: [{deptId: 1, deptName: "开发部"}, {deptId: 2, deptName: "测试部"}]}
                    //console.log(result);
                    //显示部门信息在下拉列表中
                    //$("#empAddModal select")
                    $.each(result.extend.depts, function () {
                        var optionEle = $("<option></option>").append(this.deptName).attr("value", this.deptId);
                        optionEle.appendTo(ele);
                    });
                }
            });
        }
    </script>
    <script>
        $(function () {
            //编辑按钮单击
            //1.我们是按钮创建之前就绑定了click，所以绑定不上
            //解决方法:
            //1).可以在创建按钮的时候绑定 2).绑定点击live
            //jquery新版没有live,使用on进行代替
            $(document).on("click", ".edit_btn", function () {
                //alert("edit");
                //1.查出部门信息，并显示部门列表
                getDepts("#empUpdateModal select");
                //2.查出员工信息，显示员工列表
                getEmp($(this).attr("edit-id"));

                //3.把员工id传递给模态框的更新按钮
                $("#emp_update_btn").attr("edit-id", $(this).attr("edit-id"));
                //弹出模态框
                $("#empUpdateModal").modal({
                    backdrop: "static"
                });

            });

            //为更新按钮绑定单击事件
            $("#emp_update_btn").click(function () {
                //1.验证邮箱是否合法
                if (!validate_email("#email_update_input")) {
                    return false;
                }

                //2.发送ajax请求保存更新的员工数据
                $.ajax({
                    url: "${pageContext.request.contextPath }/emp/" + $(this).attr("edit-id"),
                    type: "PUT",
                    data: $("#empUpdateModal form").serialize(),
                    success: function (result) {
                        //alert(result.msg);
                        //1.关闭对话框
                        $("#empUpdateModal").modal("hide");
                        //2.回到本页
                        to_page(currentPage);
                    }
                });

            });

            //删除按钮单击 单个删除
            $(document).on("click", ".delete_btn", function () {
                //1.弹出是否确认删除按钮对话框
                var empName = $(this).parents("tr").find("td:eq(2)").text();
                var empId = $(this).attr("del-id");
                //alert($(this).parents("tr").find("td:eq(1)").text());
                if (confirm("确认删除【" + empName + "】吗?")) {
                    //确认，发送ajax请求即可
                    $.ajax({
                        url: "${pageContext.request.contextPath }/emp/" + empId,
                        type: "DELETE",
                        success: function (result) {
                            alert(result.msg);
                            //回到本页
                            to_page(currentPage);
                        }

                    });
                }
            });

            //完成全选/全不选功能
            $("#check_all").click(function () {
                //attr获取checked是undefined;
                //我们这些dom原生的属性;attr获取自定义属性的值
                //prop读取和修改原生dom属性的值
                $(".check_item").prop("checked", $(this).prop("checked"));
            });

            //check_item 动态创建的元素
            $(document).on("click", ".check_item", function () {
                //判断当前页面元素是否全部选满
                var flag = $(".check_item:checked").length == $(".check_item").length;
                $("#check_all").prop("checked", flag);
            });

            //点击全部删除，就批量删除
            $("#emp_delete_all_btn").click(function () {
                var empNames = "";
                var del_idstr = "";
                $.each($(".check_item:checked"), function () {
                    //this
                    empNames += $(this).parents("tr").find("td:eq(2)").text() + ",";
                    //组装员工id字符串
                    del_idstr += $(this).parents("tr").find("td:eq(1)").text() + "-";
                });

                //去除empNames多余的,
                empNames = empNames.substring(0, empNames.length-1);
                //去除empNames多余的-
                del_idstr = del_idstr.substring(0, del_idstr.length-1);

                if (confirm("确认删除【"+empNames+"】吗？")){
                    //发送ajax请求删除
                    $.ajax({
                        url: "${pageContext.request.contextPath }/emp/" + del_idstr,
                        type: "DELETE",
                        success: function (result) {
                            alert(result.msg);
                            //回到当前页面
                            to_page(currentPage);
                        }
                    })
                } 
            });




        });

        function getEmp(id) {
            $.ajax({
                url: "${pageContext.request.contextPath }/emp/" + id,
                type: "GET",
                success: function (result) {
                    //console.info(result);
                    var empData = result.extend.emp;
                    $("#empName_update_static").text(empData.empName);
                    $("#email_update_input").val(empData.email);
                    $("#empUpdateModal input[name=gender]").val([empData.gender]);
                    $("#empUpdateModal select").val([empData.dId]);
                }
            })
        }

    </script>
</head>

<body>
<!-- 员工修改的模态框 -->
<div class="modal fade" id="empUpdateModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span>
                </button>
                <h4 class="modal-title">员工修改</h4>
            </div>
            <div class="modal-body">
                <form class="form-horizontal">
                    <div class="form-group">
                        <label class="col-sm-2 control-label">empName</label>
                        <div class="col-sm-10">
                            <p class="form-control-static" id="empName_update_static"></p>
                            <span class="help-block"></span>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-2 control-label">email</label>
                        <div class="col-sm-10">
                            <input type="text" name="email" class="form-control" id="email_update_input"
                                   placeholder="email@163.com">
                            <span class="help-block"></span>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-2 control-label">gender</label>
                        <div class="col-sm-10">
                            <label class="radio-inline">
                                <input type="radio" name="gender" id="gender1_update_input" value="M" checked="checked">
                                男
                            </label>
                            <label class="radio-inline">
                                <input type="radio" name="gender" id="gender2_update_input" value="F"> 女
                            </label>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-2 control-label">deptName</label>
                        <div class="col-sm-4">
                            <%-- 部门提交部门id即可 --%>
                            <select class="form-control" name="dId">
                            </select>
                        </div>
                    </div>


                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" id="emp_update_btn">更新</button>
            </div>
        </div>
    </div>
</div>

<!-- 员工添加的模态框 -->
<div class="modal fade" id="empAddModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span>
                </button>
                <h4 class="modal-title" id="myModalLabel">员工添加</h4>
            </div>
            <div class="modal-body">
                <form class="form-horizontal">
                    <div class="form-group">
                        <label class="col-sm-2 control-label">empName</label>
                        <div class="col-sm-10">
                            <input type="text" name="empName" class="form-control" id="empName_add_input"
                                   placeholder="empName"/>
                            <span class="help-block"></span>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-2 control-label">email</label>
                        <div class="col-sm-10">
                            <input type="text" name="email" class="form-control" id="email_add_input"
                                   placeholder="email@163.com">
                            <span class="help-block"></span>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-2 control-label">gender</label>
                        <div class="col-sm-10">
                            <label class="radio-inline">
                                <input type="radio" name="gender" id="gender1_add_input" value="M" checked="checked"> 男
                            </label>
                            <label class="radio-inline">
                                <input type="radio" name="gender" id="gender2_add_input" value="F"> 女
                            </label>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-2 control-label">deptName</label>
                        <div class="col-sm-4">
                            <%-- 部门提交部门id即可 --%>
                            <select class="form-control" name="dId">
                            </select>
                        </div>
                    </div>


                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" id="emp_save_btn">保存</button>
            </div>
        </div>
    </div>
</div>
<%-- 搭建显示页面 --%>
<div class="container">
    <%-- 标题行 --%>
    <div class="row">
        <div class="col-md-12">
            <h1>SSM-CURD</h1>
        </div>
    </div>
    <%-- 按钮 --%>
    <div class="row">
        <div class="col-md-4 col-md-offset-8">
            <button class="btn btn-primary" id="emp_add_modal_btn">新增</button>
            <button class="btn btn-danger" id="emp_delete_all_btn">删除</button>
        </div>
    </div>
    <%-- 显示表格数据 --%>
    <div class="row">
        <div class="col-md-12">
            <table class="table table-hover" id="emps_table">
                <thead>
                <tr>
                    <th>
                        <input type="checkbox" id="check_all"/>
                    </th>
                    <th>#</th>
                    <th>empName</th>
                    <th>gender</th>
                    <th>email</th>
                    <th>deptName</th>
                    <th>操作</th>
                </tr>
                </thead>
                <tbody>


                </tbody>

            </table>
        </div>
    </div>
    <%-- 显示分页信息 --%>
    <div class="row">
        <%--分页文字信息--%>
        <div class="col-md-6" id="page_info_area">

        </div>
        <%--分页条信息--%>
        <div class="col-md-6" id="page_nav_area">

        </div>
    </div>

</div>

</body>
</html>
