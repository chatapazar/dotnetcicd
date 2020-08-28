using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Test.Models;

namespace Test.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CustomersController : ControllerBase
    {
        // GET api/customers
        [HttpGet]
        public ActionResult<IEnumerable<Customer>> Get()
        {
            //return new string[] { "chatchai", "surachai", "kittichade" };
            string appversion = Environment.GetEnvironmentVariable("app.version");
            Customer[] C = new Customer[3];
            C[0] = new Customer { CustName  = "chatchai kongmanee:"+appversion, CustNo = "2020080001", PolicyNo = "20200800001"};
			C[1] = new Customer { CustName  = "surachai kongmanee:"+appversion, CustNo = "2020080002", PolicyNo = "20200800002"};
            C[2] = new Customer { CustName  = "sirikwan kongmanee:"+appversion, CustNo = "2020080003", PolicyNo = "20200800003"};
            
			return C;
        }

        // GET api/customers/5
        [HttpGet("{id}")]
        public ActionResult<Customer> Get(int id)
        {
            return new Customer { CustName  = "chatchai kongmanee", CustNo = "2020080001", PolicyNo = "20200800001"};
        }

    }
}
