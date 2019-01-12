package com.lx.crud.servcie;

import com.lx.crud.bean.Department;
import com.lx.crud.dao.DepartmentMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class DepartmentService {

    @Autowired
    private DepartmentMapper departmentMapper;

    /**
     * @return 查出的所有部门信息
     */
    public List<Department> getDepts() {
        return departmentMapper.selectByExample(null);
    }
}
