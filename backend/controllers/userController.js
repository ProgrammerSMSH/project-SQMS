const User = require('../models/User');

// @desc    Get all staff members
// @route   GET /api/v1/users/staff
// @access  Private/Admin
const getStaffMembers = async (req, res, next) => {
  try {
    const staff = await User.find({ role: 'STAFF' }).select('-password');
    res.json(staff);
  } catch (error) {
    next(error);
  }
};

// @desc    Create a staff member
// @route   POST /api/v1/users/staff
// @access  Private/Admin
const createStaffMember = async (req, res, next) => {
  try {
    const { name, email, password, phone } = req.body;

    const userExists = await User.findOne({ email });
    if (userExists) {
      res.status(400);
      throw new Error('User already exists');
    }

    const staff = await User.create({
      name,
      email,
      password,
      phone,
      role: 'STAFF'
    });

    if (staff) {
      res.status(201).json({
        _id: staff._id,
        name: staff.name,
        email: staff.email,
        role: staff.role
      });
    } else {
      res.status(400);
      throw new Error('Invalid staff data');
    }
  } catch (error) {
    next(error);
  }
};

// @desc    Delete a staff member
// @route   DELETE /api/v1/users/staff/:id
// @access  Private/Admin
const deleteStaffMember = async (req, res, next) => {
    try {
      const user = await User.findById(req.params.id);
      if (!user) {
        res.status(404);
        throw new Error('Staff member not found');
      }
      
      await user.deleteOne();
      res.json({ message: 'Staff member removed' });
    } catch (error) {
      next(error);
    }
};

module.exports = { getStaffMembers, createStaffMember, deleteStaffMember };
